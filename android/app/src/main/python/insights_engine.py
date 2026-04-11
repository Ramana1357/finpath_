import json

def calculate_on_device(transaction_list_json, physical_cash):
    """
    Pure Python implementation - No heavy dependencies like Pandas.
    transaction_list_json: A JSON string containing the list of transactions.
    physical_cash: float
    """
    try:
        transactions = json.loads(transaction_list_json)
        
        income = 0.0
        expenses = 0.0
        
        # Simple Math (No Pandas needed)
        for tx in transactions:
            # Handle potential string or numeric types from JSON
            try:
                amount = float(tx.get('amount', 0))
            except (ValueError, TypeError):
                amount = 0.0
                
            if tx.get('isExpense', True):
                expenses += amount
            else:
                income += amount
        
        # Calculate Health Score
        savings = income - expenses
        health_score = 0
        if income > 0:
            health_score = max(0, min(100, int((savings / income) * 100)))
        
        # Reverse Audit Logic (Cash Leakage)
        expected_balance = income - expenses
        leakage = max(0.0, expected_balance - float(physical_cash))
        
        # Return statistics to Flutter/Kotlin
        result = {
            "health_score": health_score,
            "income": income,
            "expenses": expenses,
            "leakage": leakage,
            "status": "success"
        }
        
        return json.dumps(result)
        
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})
