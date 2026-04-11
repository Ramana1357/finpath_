import json

def calculate_on_device(transaction_list_json, physical_cash=0):
    """
    Pure Math Engine - No AI calls.
    Returns raw stats for the Dart AI Coach to process.
    """
    try:
        transactions = json.loads(transaction_list_json)
        
        income = 0.0
        expenses = 0.0
        categories = {}
        
        for tx in transactions:
            try:
                amount = float(tx.get('amount', 0))
            except (ValueError, TypeError):
                amount = 0.0
                
            if tx.get('isExpense', True):
                expenses += amount
                title = tx.get('title', 'Other').lower()
                
                if any(word in title for word in ['zomato', 'swiggy', 'food']): cat = "Food"
                elif any(word in title for word in ['amazon', 'flipkart']): cat = "Shopping"
                elif any(word in title for word in ['uber', 'ola']): cat = "Transport"
                else: cat = "Other"
                
                categories[cat] = categories.get(cat, 0) + amount
            else:
                income += amount
        
        savings = income - expenses
        health_score = max(0, min(100, int((savings / income) * 100))) if income > 0 else 0
        
        return json.dumps({
            "health_score": health_score,
            "income": income,
            "expenses": expenses,
            "categories": categories,
            "status": "success"
        })
        
    except Exception as e:
        return json.dumps({"status": "error", "message": str(e)})
