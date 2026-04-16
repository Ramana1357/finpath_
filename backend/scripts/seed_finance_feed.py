import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import time

# 1. Connect to your specific Firebase Vault
cred = credentials.Certificate('backend/finpath-58f47-firebase-adminsdk-fbsvc-7994e97a0d.json')

# Prevent initializing multiple times
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

# 2. Your Curated List of Tips
tips = [
    {
        "type": "book_lesson",
        "title": "Pay Yourself First",
        "source": "Rich Dad Poor Dad",
        "content": "Before paying your bills, set aside your 20% savings. This forces you to be innovative to cover the rest.",
        "image_url": "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e",
        "timestamp": int(time.time())
    },
    {
        "type": "market_rule",
        "title": "Time in the Market",
        "source": "Warren Buffett",
        "content": "The stock market is a device for transferring money from the impatient to the patient.",
        "image_url": "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3",
        "timestamp": int(time.time()) - 86400
    }
    # Add the rest of your 50 tips here...
]

# 3. The Upload Engine
print("Uploading tips to Firebase...")
collection_ref = db.collection('finance_feed')

for tip in tips:
    # This automatically creates a new document with a random ID
    collection_ref.add(tip)
    print(f"✅ Uploaded: {tip['title']}")

print("All done! Your Finance Feed is live.")