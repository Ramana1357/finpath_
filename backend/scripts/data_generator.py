import random
from datetime import datetime, timedelta
import sys
import os

# Add the root backend directory to sys.path so we can import services
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.firebase_service import initialize_firebase, get_db
import sys
import os

# Add root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import insights engine
from analytics.insights import push_insights_to_firestore

def generate_fake_transactions(user_id, count=50):
    db = initialize_firebase()
    
    categories = ["Zomato", "Amazon", "Uber", "Groceries", "Rent", "Salary", "Netflix", "Gym", "Starbucks", "Gas"]
    
    batch = db.batch()
    
    for i in range(count):
        category = random.choice(categories)
        is_expense = category != "Salary"
        amount = round(random.uniform(10.0, 2000.0), 2) if is_expense else 50000.0
        
        # Generate a random date within the last 30 days
        date = datetime.now() - timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))
        
        transaction_data = {
            "title": category,
            "amount": amount,
            "date": date,
            "isExpense": is_expense,
            "smsRawText": f"Generated test message for {category}",
            "userId": user_id # Associate with a user
        }
        
        doc_ref = db.collection("transactions").document()
        batch.set(doc_ref, transaction_data)
        
    batch.commit()
    print(f"Successfully pushed {count} transactions for user {user_id}")
    
    # NEW: Automatically trigger analysis
    print(f"Triggering insights calculation for {user_id}...")
    push_insights_to_firestore(user_id)

def get_all_recent_users(db, limit=5):
    """Detects the most recent unique userIds from 'users' and 'transactions' collections."""
    # 1. Check the new 'users' collection (most reliable for fresh installs)
    user_docs = db.collection("users").order_by("lastSeen", direction="DESCENDING").limit(limit).get()
    uids = [doc.id for doc in user_docs]
    
    # 2. Backup: Check the 'transactions' collection
    if len(uids) < limit:
        txn_docs = db.collection("transactions").order_by("date", direction="DESCENDING").limit(50).get()
        for doc in txn_docs:
            uid = doc.to_dict().get("userId")
            if uid and uid not in uids:
                uids.append(uid)
                if len(uids) >= limit: break
            
    return uids

if __name__ == "__main__":
    db = initialize_firebase()
    
    # Target ONLY the single most recent user to save cost/time
    active_users = get_all_recent_users(db, limit=1)
    
    if not active_users:
        print("No user detected. Check Firestore 'users' collection.")
        sys.exit(0)
        
    user_id = active_users[0]
    print(f"\n--- Processing Active User: {user_id} ---")
    
    # Mark as "Syncing"
    db.collection("insights").document(user_id).set({
        "status": "Syncing Data...",
        "lastUpdated": datetime.now()
    }, merge=True)

    generate_fake_transactions(user_id, count=10)
