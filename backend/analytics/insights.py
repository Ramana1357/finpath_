import sys
import os
from pathlib import Path
import json
import statistics
from datetime import datetime
from firebase_admin import firestore
from google import genai
from dotenv import load_dotenv

# Now import from the services package
try:
    from services.firebase_service import get_db, initialize_firebase
except ImportError:
    # Fallback for different execution contexts
    sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
    from services.firebase_service import get_db, initialize_firebase

# Load environment variables robustly
current_dir = os.path.dirname(os.path.abspath(__file__))
backend_root = os.path.dirname(current_dir)
env_path = os.path.join(backend_root, '.env')
load_dotenv(dotenv_path=env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# Configure Gemini using new google-genai SDK
if GEMINI_API_KEY and GEMINI_API_KEY != "YOUR_KEY_HERE":
    client = genai.Client(api_key=GEMINI_API_KEY)
else:
    client = None

def get_ai_summaries(health_score, top_categories, anomalies):
    """Uses Gemini to generate creative financial coaching messages."""
    if not client:
        return fallback_summaries(health_score, top_categories, anomalies)

    prompt = f"""
    You are a helpful, slightly witty financial coach for a college student.
    Based on their financial data, generate 3 short coaching cards in JSON format.
    
    Data:
    - Health Score: {health_score}/100
    - Top Spending: {top_categories}
    - Anomalies: {anomalies}
    
    Return ONLY a JSON list of objects with these keys:
    "type": (one of: positive, negative, neutral, warning, alert, anomaly)
    "title": (short catchy title)
    "message": (1-2 sentences of witty, actionable advice)
    """
    
    try:
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt
        )
        text = response.text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
            
        return json.loads(text)
    except Exception as e:
        print(f"Gemini Error: {e}")
        return fallback_summaries(health_score, top_categories, anomalies)

def fallback_summaries(health_score, top_categories, anomalies):
    """Hardcoded fallback logic."""
    summaries = []
    if health_score > 70:
        summaries.append({"type": "positive", "title": "Great Job!", "message": "Your financial health is looking strong. Keep it up!"})
    else:
        summaries.append({"type": "neutral", "title": "Keep Tracking", "message": "Continue tracking your spends to get better AI insights."})
    return summaries

def get_user_transactions(user_id):
    """Fetches all transactions for a specific user from Firestore."""
    db = get_db()
    docs = db.collection("transactions").where(filter=firestore.FieldFilter("userId", "==", user_id)).stream()
    
    transactions = []
    for doc in docs:
        d = doc.to_dict()
        d['id'] = doc.id
        # Convert date to string if it's a timestamp
        if 'date' in d and hasattr(d['date'], 'isoformat'):
            d['date'] = d['date'].isoformat()
        transactions.append(d)
    return transactions

def calculate_insights(user_id):
    transactions = get_user_transactions(user_id)
    
    if not transactions:
        return {"message": "No data found for user"}

    CATEGORY_MAP = {
        "Zomato": "Food & Dining", "Swiggy": "Food & Dining", "Starbucks": "Food & Dining",
        "Amazon": "Shopping", "Flipkart": "Shopping", "Uber": "Transport", "Ola": "Transport",
        "Groceries": "Essentials", "Rent": "Fixed Costs", "Salary": "Income"
    }

    def map_category(title):
        for key, val in CATEGORY_MAP.items():
            if key.lower() in title.lower(): return val
        return "Other"

    # Aggregations using native Python
    expenses = [t for t in transactions if t.get('isExpense') == True]
    income_list = [t for t in transactions if t.get('isExpense') == False]
    
    total_spent = sum(t.get('amount', 0) for t in expenses)
    total_income = sum(t.get('amount', 0) for t in income_list)

    # Category totals
    category_totals = {}
    for t in expenses:
        cat = map_category(t.get('title', ''))
        category_totals[cat] = category_totals.get(cat, 0) + t.get('amount', 0)
    
    top_categories = []
    for category, amount in category_totals.items():
        percentage = (amount / total_spent) * 100 if total_spent > 0 else 0
        top_categories.append({"category": category, "amount": float(amount), "percentage": round(percentage, 2)})

    savings_rate = (total_income - total_spent) / total_income if total_income > 0 else 0
    health_score = max(0, min(100, int(savings_rate * 100)))

    # Anomaly detection using statistics module
    anomalies = []
    expense_amounts = [t.get('amount', 0) for t in expenses]
    if len(expense_amounts) > 1:
        mean_val = statistics.mean(expense_amounts)
        std_dev = statistics.stdev(expense_amounts)
        threshold = mean_val + (2 * std_dev)
        
        for t in expenses:
            if t.get('amount', 0) > threshold:
                anomalies.append({"title": t.get('title'), "amount": t.get('amount'), "date": t.get('date')})

    feed_summaries = get_ai_summaries(health_score, top_categories, anomalies)

    return {
        "userId": user_id,
        "top_categories": sorted(top_categories, key=lambda x: x['amount'], reverse=True)[:4],
        "health_score": health_score,
        "anomalies": anomalies,
        "feed_summaries": feed_summaries,
        "lastUpdated": datetime.now()
    }

def push_insights_to_firestore(user_id):
    db = get_db()
    insights = calculate_insights(user_id)
    if "message" in insights: return
    db.collection("insights").document(user_id).set(insights)
    print(f"Successfully pushed insights for user {user_id}")

if __name__ == "__main__":
    try:
        db = get_db()
    except Exception:
        db = initialize_firebase()
    
    print("Searching for active users...")
    docs = db.collection("transactions").limit(50).stream()
    active_users = set()
    for doc in docs:
        uid = doc.to_dict().get("userId")
        if uid: active_users.add(uid)
    
    if not active_users:
        print("No active users found.")
    else:
        for user_id in active_users:
            try:
                push_insights_to_firestore(user_id)
            except Exception as e:
                print(f"Error processing user {user_id}: {e}")
