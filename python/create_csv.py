def transwrite(date,time,transID,amount,bank):
    import csv
    with open('transactions.csv', 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([date,time,transID,amount,bank])
        
for i in range(1):
    date = input("Enter the date (YYYY-MM-DD): ")
    time = input("Enter the time (HH:MM:SS): ")
    transID = input("Enter the transaction ID: ")
    amount = input("Enter the amount: ")
    bank = input("Enter the bank name: ")
    transwrite(date,time,transID,amount,bank)