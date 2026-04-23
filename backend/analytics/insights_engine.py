import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import calendar

# ---------------------------------------------------------
# 1. FIREBASE SETUP
# ---------------------------------------------------------
# Replace 'firebase_key.json' with your actual service account key file
cred = credentials.Certificate("backend/finpath-58f47-firebase-adminsdk-fbsvc-7994e97a0d.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# ---------------------------------------------------------
# 2. CATEGORY MAPPING
# ---------------------------------------------------------
def map_category_to_bucket(category):
    """Maps your app's categories to the 50/30/20 buckets."""
    category = category.lower()

    # Adjust these lists based on the exact strings your app saves!
    needs = ['food', 'groceries', 'rent', 'utilities', 'education', 'transport', 'health']
    wants = ['shopping', 'dining', 'entertainment', 'hobbies', 'subscriptions']

    if category in needs:
        return 'needs'
    elif category in wants:
        return 'wants'
    else:
        # Defaulting unknown or explicit 'investments' to savings
        return 'savings'

# ---------------------------------------------------------
# 3. THE CORE ENGINE
# ---------------------------------------------------------
def generate_monthly_insights(user_id, monthly_allowance):
    print(f"Crunching data for user: {user_id}...")

    # Calculate the exact time window for the current month
    now = datetime.now()
    month_id = now.strftime("%Y-%m") # e.g., "2026-04"
    _, last_day = calendar.monthrange(now.year, now.month)

    start_date = datetime(now.year, now.month, 1)
    end_date = datetime(now.year, now.month, last_day, 23, 59, 59)

    # Fetch Transactions from Firestore
    transactions_ref = db.collection('profiles').document(user_id).collection('transactions')
    query = transactions_ref.where('date', '>=', start_date).where('date', '<=', end_date)
    docs = query.stream()

    # Initialize totals
    totals = {'needs': 0.0, 'wants': 0.0, 'savings': 0.0}

    # Sort and sum the transactions
    for doc in docs:
        data = doc.to_dict()
        if data.get('type') == 'expense':
            amount = float(data.get('amount', 0))
            bucket = map_category_to_bucket(data.get('category', ''))
            totals[bucket] += amount

    # Calculate 50/30/20 Percentages
    # Safety check to prevent division by zero
    if monthly_allowance > 0:
        needs_pct = round((totals['needs'] / monthly_allowance) * 100, 1)
        wants_pct = round((totals['wants'] / monthly_allowance) * 100, 1)
        savings_pct = round((totals['savings'] / monthly_allowance) * 100, 1)
    else:
        needs_pct = wants_pct = savings_pct = 0.0

    # Calculate Financial Health Score (0-100)
    # Starts at 100, penalizes for breaking the 50/30/20 rule
    health_score = 100.0
    if needs_pct > 50:
        health_score -= (needs_pct - 50)
    if wants_pct > 30:
        health_score -= (wants_pct - 30)
    if savings_pct < 20:
        health_score -= (20 - savings_pct)

    # Clamp the score strictly between 0 and 100
    final_health_score = int(max(0, min(100, round(health_score))))

    # ---------------------------------------------------------
    # 4. PACKAGE AND PUSH TO FIREBASE
    # ---------------------------------------------------------
    # Note: These keys explicitly match the Isar model variables
    # we just told your developer agent to create.
    insights_data = {
        'monthId': month_id,
        'needsTotal': totals['needs'],
        'wantsTotal': totals['wants'],
        'savingsTotal': totals['savings'],
        'needsPct': needs_pct,
        'wantsPct': wants_pct,
        'savingsPct': savings_pct,
        'healthScore': final_health_score,
        'lastUpdated': firestore.SERVER_TIMESTAMP
    }

    # Push to a dedicated 'insights' collection for this user
    insight_doc_ref = db.collection('profiles').document(user_id).collection('insights').document(month_id)
    insight_doc_ref.set(insights_data)

    print(f"✅ Success! Month: {month_id} | Health Score: {final_health_score}")
    print(f"Needs: {needs_pct}% | Wants: {wants_pct}% | Savings: {savings_pct}%")


# ---------------------------------------------------------
# EXECUTION (For testing locally)
# ---------------------------------------------------------
# ---------------------------------------------------------
# 5. PRODUCTION BATCH PROCESSING
# ---------------------------------------------------------
def process_all_users():
    print("🚀 Starting FinPath Batch Analytics Engine...")

    # Grab every single user profile from Firestore
    users_ref = db.collection('profiles')
    docs = users_ref.stream()

    success_count = 0
    fail_count = 0

    for doc in docs:
        user_id = doc.id
        user_data = doc.to_dict()

        # Check if they have set an allowance in their profile.
        # Note: Change 'monthlyAllowance' to whatever exactly you named it in Firestore!
        monthly_allowance = user_data.get('monthlyAllowance', 0)

        try:
            # Run the engine for this specific user
            generate_monthly_insights(user_id=user_id, monthly_allowance=monthly_allowance)
            success_count += 1
        except Exception as e:
            print(f"❌ Error processing user {user_id}: {e}")
            fail_count += 1

    print("-" * 40)
    print(f"🏁 Batch complete! Success: {success_count} | Failed: {fail_count}")

# ---------------------------------------------------------
# EXECUTION (Production)
# ---------------------------------------------------------
if __name__ == "__main__":
    # This will now process EVERY user in your database automatically.
    process_all_users()