import sys
import os
import pandas as pd
from google import genai
from dotenv import load_dotenv
import json

# Add root to path BEFORE importing local modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from firebase_admin import firestore
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
        # Reverting to the most stable 1.5-flash with highest free quota
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt
        )
        text = response.text.strip()
        # Handle cases where Gemini wraps JSON in markdown
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
    
    data = []
    for doc in docs:
        d = doc.to_dict()
        d['id'] = doc.id
        if 'date' in d and hasattr(d['date'], 'isoformat'):
            d['date'] = d['date'].isoformat()
        data.append(d)
        
    return pd.DataFrame(data)

def calculate_insights(user_id):
    df = get_user_transactions(user_id)
    
    if df.empty:
        return {"message": "No data found for user"}

    # --- CATEGORY MAPPING ---
    CATEGORY_MAP = {
        "Zomato": "Food & Dining", "Swiggy": "Food & Dining", "Starbucks": "Food & Dining",
        "Amazon": "Shopping", "Flipkart": "Shopping", "Uber": "Transport", "Ola": "Transport",
        "Groceries": "Essentials", "Rent": "Fixed Costs", "Salary": "Income"
    }

    def map_category(title):
        for key, val in CATEGORY_MAP.items():
            if key.lower() in title.lower(): return val
        return "Other"

    df['mapped_category'] = df['title'].apply(map_category)
    expenses = df[df['isExpense'] == True]
    total_spent = expenses['amount'].sum()
    category_totals = expenses.groupby('mapped_category')['amount'].sum().sort_values(ascending=False)
    
    top_categories = []
    for category, amount in category_totals.items():
        percentage = (amount / total_spent) * 100 if total_spent > 0 else 0
        top_categories.append({"category": category, "amount": float(amount), "percentage": round(percentage, 2)})

    income = df[df['isExpense'] == False]['amount'].sum()
    savings_rate = (income - total_spent) / income if income > 0 else 0
    health_score = max(0, min(100, int(savings_rate * 100)))

    anomalies = []
    if not expenses.empty and expenses['amount'].std() > 0:
        threshold = expenses['amount'].mean() + (2 * expenses['amount'].std())
        outliers = expenses[expenses['amount'] > threshold]
        for _, row in outliers.iterrows():
            anomalies.append({"title": row['title'], "amount": row['amount'], "date": row['date']})

    db = get_db()
    audit_doc = db.collection("audits").document(user_id).get()
    physical_cash_reported = audit_doc.to_dict().get('cash_on_hand', 0) if audit_doc.exists else 0
    expected_balance = income - total_spent
    leakage = max(0, expected_balance - physical_cash_reported)
    
    if leakage > 0:
        top_categories.append({"category": "Unaccounted (Cash)", "amount": float(leakage), "percentage": round((leakage / income) * 100, 2) if income > 0 else 0})
        health_score = max(0, health_score - int((leakage / income) * 50)) if income > 0 else health_score

    feed_summaries = get_ai_summaries(health_score, top_categories, anomalies)

    return {
        "userId": user_id,
        "top_categories": sorted(top_categories, key=lambda x: x['amount'], reverse=True)[:4],
        "health_score": health_score,
        "anomalies": anomalies,
        "feed_summaries": feed_summaries,
        "physical_cash_balance": float(physical_cash_reported),
        "lastUpdated": pd.Timestamp.now()
    }

def push_insights_to_firestore(user_id):
    db = get_db()
    insights = calculate_insights(user_id)
    if "message" in insights: return
    db.collection("insights").document(user_id).set(insights)
    print(f"Successfully pushed insights for user {user_id}")

if __name__ == "__main__":
    db = initialize_firebase()
    from scripts.data_generator import get_all_recent_users
    active_users = get_all_recent_users(db, limit=1)
    for user_id in active_users:
        push_insights_to_firestore(user_id)
