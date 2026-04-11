import firebase_admin
from firebase_admin import credentials, firestore
import os
from dotenv import load_dotenv

# Get the directory of this file (services/)
current_dir = os.path.dirname(os.path.abspath(__file__))
# Get the backend root directory
backend_root = os.path.dirname(current_dir)
# Path to .env file
env_path = os.path.join(backend_root, '.env')

load_dotenv(dotenv_path=env_path)

def initialize_firebase():
    """Initializes the Firebase Admin SDK."""
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_JSON')
    
    if not service_account_path:
        raise ValueError(f"FIREBASE_SERVICE_ACCOUNT_JSON not found in .env file at {env_path}")
    
    # If the path in .env is relative, make it absolute relative to backend root
    if not os.path.isabs(service_account_path):
        service_account_path = os.path.join(backend_root, service_account_path)
        
    if not os.path.exists(service_account_path):
        raise FileNotFoundError(f"Service Account JSON not found at: {service_account_path}")

    if not firebase_admin._apps:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred)
    
    return firestore.client()

def get_db():
    return firestore.client()
