def sendtrans(period):
    import csv
    with open('transactions.csv', 'r') as file:
        reader = csv.reader(file)
        transactions = list(reader)
    # Filter transactions based on the specified period
    filtered_transactions = []
    for transaction in transactions:
        if transaction[0] == period:  # Assuming date is the first column
            filtered_transactions.append(transaction)
    return filtered_transactions