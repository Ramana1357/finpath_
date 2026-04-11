import sys
import os

# Add root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.firebase_service import initialize_firebase

def cleanup_old_users(keep_user_id):
    db = initialize_firebase()
    
    # List of collections to clean
    collections = ["transactions", "insights", "audits"]
    
    print(f"Starting cleanup. Keeping user: {keep_user_id}")
    
    for coll_name in collections:
        print(f"Checking collection: {coll_name}...")
        
        if coll_name == "transactions":
            # Search by field 'userId'
            docs = db.collection(coll_name).where("userId", "!=", keep_user_id).stream()
        else:
            # Search by document ID (since insights and audits use UID as doc name)
            # Firestore doesn't support != on doc IDs directly in stream() easily without fetching all
            # So we fetch all and filter
            docs = db.collection(coll_name).stream()
            
        count = 0
        for doc in docs:
            # For transactions, we already filtered by userId field
            # For others, we filter by doc ID
            if coll_name != "transactions" and doc.id == keep_user_id:
                continue
                
            doc.reference.delete()
            count += 1
            
        print(f"Deleted {count} documents from {coll_name}.")

if __name__ == "__main__":
    # The ID confirmed by the user
    CURRENT_USER_ID = "FgSF0qDCCNRL3WluMIAI2jK1DDm1"
    cleanup_old_users(CURRENT_USER_ID)
    print("\nCleanup complete! Your database is now tidy.")
