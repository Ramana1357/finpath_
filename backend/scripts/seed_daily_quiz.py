import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# 1. Connect to your specific Firebase Vault (Path corrected for root terminal execution)
cred = credentials.Certificate('backend/finpath-58f47-firebase-adminsdk-fbsvc-7994e97a0d.json')

# Prevent initializing multiple times if you run the script back-to-back
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

# 2. Your AI-Generated Quiz Bank (Batch 1: April 17 - May 1)
quizzes = [
    {
            "date_string": "2026-05-02",
            "question": "What is the standard range for a FICO Credit Score?",
            "options": [
                "0 to 100",
                "300 to 850",
                "1000 to 5000"
            ],
            "correct_index": 1,
            "explanation": "FICO scores range from 300 to 850. A score above 740 is generally considered 'Very Good' and unlocks the best interest rates for loans.",
            "points": 50
        },
        {
            "date_string": "2026-05-03",
            "question": "What does a 'Bull Market' indicate?",
            "options": [
                "Stock prices are falling and investors are scared",
                "Stock prices are rising and the economy is optimistic",
                "The market has completely crashed"
            ],
            "correct_index": 1,
            "explanation": "Think of a bull thrusting its horns upward. A bull market means investor confidence is high and asset prices are trending up.",
            "points": 50
        },
        {
            "date_string": "2026-05-04",
            "question": "What is the fundamental difference between a Debit Card and a Credit Card?",
            "options": [
                "Debit uses your own money; Credit uses borrowed money",
                "Credit cards have no limits; Debit cards do",
                "Debit cards build your credit score; Credit cards do not"
            ],
            "correct_index": 0,
            "explanation": "A debit card pulls cash directly from your bank account. A credit card is a short-term loan from the bank that you must pay back.",
            "points": 50
        },
        {
            "date_string": "2026-05-05",
            "question": "What is a Mutual Fund?",
            "options": [
                "A secret account for rich investors",
                "A pool of money from many investors managed by a professional",
                "A government fund to pay off student debt"
            ],
            "correct_index": 1,
            "explanation": "Mutual funds collect money from thousands of people to buy a massive, diversified portfolio of stocks or bonds, managed by an expert.",
            "points": 50
        },
        {
            "date_string": "2026-05-06",
            "question": "What is the 'Rule of 72' used for in finance?",
            "options": [
                "Calculating how many months you have to pay taxes",
                "Estimating how many years it will take for your money to double",
                "The maximum percentage of income you should spend on rent"
            ],
            "correct_index": 1,
            "explanation": "Divide 72 by your annual interest rate. If you earn 8% a year, 72 ÷ 8 = 9. Your money will double in roughly 9 years.",
            "points": 50
        },
        {
            "date_string": "2026-05-07",
            "question": "In the context of loans, what is 'Amortization'?",
            "options": [
                "The process of paying off a debt with regular, scheduled payments",
                "The penalty fee for paying off a loan too early",
                "When the bank forgives your debt"
            ],
            "correct_index": 0,
            "explanation": "Amortization spreads your loan into equal monthly payments, where part goes to interest and part goes to reducing the principal balance.",
            "points": 50
        },
        {
            "date_string": "2026-05-08",
            "question": "When you buy a 'Bond', what are you actually doing?",
            "options": [
                "Buying a small piece of ownership in a company",
                "Lending your money to a company or government for a set time",
                "Opening a high-yield savings account"
            ],
            "correct_index": 1,
            "explanation": "A bond is an I.O.U. You lend money to an entity, and they promise to pay you back with regular interest payments.",
            "points": 50
        },
        {
            "date_string": "2026-05-09",
            "question": "What does the financial acronym 'ROI' stand for?",
            "options": [
                "Rate of Inflation",
                "Return on Investment",
                "Risk Over Income"
            ],
            "correct_index": 1,
            "explanation": "Return on Investment measures the profitability of an investment. It is the net profit divided by the original cost of the investment.",
            "points": 50
        },
        {
            "date_string": "2026-05-10",
            "question": "What is a 'Capital Gains Tax'?",
            "options": [
                "A tax on the profit you make when selling an asset like stocks or real estate",
                "A yearly tax on the money sitting in your checking account",
                "A fee paid when you open a new brokerage account"
            ],
            "correct_index": 0,
            "explanation": "If you buy a stock for ₹1,000 and sell it for ₹1,500, you must pay capital gains tax on the ₹500 profit.",
            "points": 50
        },
        {
            "date_string": "2026-05-11",
            "question": "What is 'Phishing' in financial cybersecurity?",
            "options": [
                "Using an algorithm to buy stocks automatically",
                "Scammers tricking you into revealing passwords or bank details",
                "The process of extracting physical cash from an ATM"
            ],
            "correct_index": 1,
            "explanation": "Phishing usually happens via fake emails or texts that look like your bank, trying to steal your login credentials.",
            "points": 50
        },
        {
            "date_string": "2026-05-12",
            "question": "Which of these assets is most famous for massive 'Depreciation'?",
            "options": [
                "Real Estate",
                "Gold",
                "A brand new car"
            ],
            "correct_index": 2,
            "explanation": "Depreciation is the loss of value over time. A new car loses about 20% of its value the minute you drive it off the dealership lot.",
            "points": 50
        },
        {
            "date_string": "2026-05-13",
            "question": "What is a 'Blue-Chip' stock?",
            "options": [
                "A highly risky startup company",
                "Shares in huge, nationally recognized, financially sound companies",
                "A company that only operates in the technology sector"
            ],
            "correct_index": 1,
            "explanation": "Named after the most expensive chips in poker, Blue-Chip stocks are massive companies (like Apple or Reliance) known for stability and reliable growth.",
            "points": 50
        },
        {
            "date_string": "2026-05-14",
            "question": "Modern money (like the Rupee or Dollar) is known as 'Fiat Money'. What makes it valuable?",
            "options": [
                "It is backed by physical gold in a vault",
                "Government decree and public trust",
                "The specific paper it is printed on"
            ],
            "correct_index": 1,
            "explanation": "Fiat money has no intrinsic value and isn't backed by gold. It works solely because the government declares it as legal tender and people trust it.",
            "points": 50
        },
        {
            "date_string": "2026-05-15",
            "question": "Which of the following is considered 'Good Debt'?",
            "options": [
                "A high-interest credit card balance used for a vacation",
                "A student loan that leads to a high-paying career",
                "A 7-year loan for a luxury sports car"
            ],
            "correct_index": 1,
            "explanation": "Good debt is an investment that eventually increases your net worth or income, like education or a mortgage on a house.",
            "points": 50
        },
        {
            "date_string": "2026-05-16",
            "question": "What does 'APR' stand for on a credit card statement?",
            "options": [
                "Annual Percentage Rate",
                "Average Payment Required",
                "Automatic Purchase Reversal"
            ],
            "correct_index": 0,
            "explanation": "APR is the yearly interest rate you will be charged if you carry a balance on your credit card from month to month.",
            "points": 50
        },
        {
            "date_string": "2026-05-17",
            "question": "What is a credit card's 'Grace Period'?",
            "options": [
                "The time you have to pay your bill in full before interest is charged",
                "A month where you don't have to make any minimum payments",
                "The time it takes for your credit score to update"
            ],
            "correct_index": 0,
            "explanation": "If you pay your entire statement balance before the grace period ends (usually 21-25 days), you pay absolutely zero interest.",
            "points": 50
        },
        {
            "date_string": "2026-05-18",
            "question": "In a large transaction, what is an 'Escrow' account?",
            "options": [
                "A secret offshore bank account",
                "A neutral third-party holding funds until the deal is completed",
                "An account strictly for stock trading"
            ],
            "correct_index": 1,
            "explanation": "Escrow protects both the buyer and seller. The money sits in a safe middle-ground until all the contracts and inspections are finalized.",
            "points": 50
        },
        {
            "date_string": "2026-05-19",
            "question": "What is the main difference between an ETF and a Mutual Fund?",
            "options": [
                "ETFs are illegal for students to buy",
                "ETFs can be traded throughout the day like normal stocks",
                "Mutual funds never lose money"
            ],
            "correct_index": 1,
            "explanation": "An Exchange-Traded Fund (ETF) fluctuates in price all day while the market is open. A Mutual Fund only updates its price once at the end of the day.",
            "points": 50
        },
        {
            "date_string": "2026-05-20",
            "question": "If a tech company gives you stock options with a 4-year 'Vesting Schedule', what does that mean?",
            "options": [
                "You get all the stocks immediately but cannot sell for 4 years",
                "You slowly earn the right to own those stocks over the 4 years",
                "The stock will expire and become worthless in 4 years"
            ],
            "correct_index": 1,
            "explanation": "Vesting is a retention tool. It ensures employees stay with the company to slowly 'unlock' their stock rewards over time.",
            "points": 50
        },
        {
            "date_string": "2026-05-21",
            "question": "What is a 'Dividend'?",
            "options": [
                "A fee the government charges you to buy stock",
                "A portion of a company's profit distributed to its shareholders",
                "The penalty for selling a stock too quickly"
            ],
            "correct_index": 1,
            "explanation": "When mature companies make excess profit, they often reward their investors by paying them cash dividends simply for holding the stock.",
            "points": 50
        },
        {
            "date_string": "2026-05-22",
            "question": "What does it mean to 'Liquidate' an asset?",
            "options": [
                "To sell it and turn it into cash",
                "To hide it from the tax authorities",
                "To pass it down to your children"
            ],
            "correct_index": 0,
            "explanation": "Liquidation is the process of bringing an asset (like stocks, bonds, or real estate) back into a liquid state, which means pure cash.",
            "points": 50
        },
        {
            "date_string": "2026-05-23",
            "question": "Who benefits the most during a period of unexpectedly high Inflation?",
            "options": [
                "People living on fixed incomes or pensions",
                "People who owe large amounts of fixed-rate debt",
                "Banks holding cash in vaults"
            ],
            "correct_index": 1,
            "explanation": "If you have a fixed-rate mortgage, high inflation means you are paying the bank back with money that is functionally worth less than when you borrowed it.",
            "points": 50
        },
        {
            "date_string": "2026-05-24",
            "question": "If a financial advisor is a 'Fiduciary', what does that legally mean?",
            "options": [
                "They are allowed to trade on inside information",
                "They must put your financial best interests above their own",
                "They work directly for the government"
            ],
            "correct_index": 1,
            "explanation": "A fiduciary cannot sell you a bad mutual fund just to earn a fat commission. They are legally bound to give you the absolute best advice for your situation.",
            "points": 50
        },
        {
            "date_string": "2026-05-25",
            "question": "What is 'Opportunity Cost'?",
            "options": [
                "The fee you pay to a stock broker",
                "The potential benefit you lose by choosing one option over another",
                "The cost of starting a new business"
            ],
            "correct_index": 1,
            "explanation": "If you spend ₹10,000 on a vacation, the opportunity cost is the wealth you *would* have gained if you had invested that ₹10,000 into the stock market instead.",
            "points": 50
        },
        {
            "date_string": "2026-05-26",
            "question": "Which of these is an example of 'Passive Income'?",
            "options": [
                "Working overtime at a retail job",
                "Freelance coding on the weekends",
                "Earning royalties from a book you wrote two years ago"
            ],
            "correct_index": 2,
            "explanation": "Passive income requires upfront work or capital, but then generates money automatically with minimal ongoing daily effort.",
            "points": 50
        },
        {
            "date_string": "2026-05-27",
            "question": "When checking your credit report, what is a 'Hard Inquiry'?",
            "options": [
                "When you check your own score on an app",
                "When a lender checks your credit because you applied for a loan",
                "When a bank permanently closes your account"
            ],
            "correct_index": 1,
            "explanation": "Checking your own score is a 'Soft Inquiry' and doesn't hurt your score. A 'Hard Inquiry' happens when you apply for new debt, which temporarily drops your score slightly.",
            "points": 50
        },
        {
            "date_string": "2026-05-28",
            "question": "What happens during a 'Stock Split'?",
            "options": [
                "The company goes bankrupt and splits its assets",
                "The company divides existing shares into multiple new shares, lowering the price",
                "The CEO is forced to resign"
            ],
            "correct_index": 1,
            "explanation": "If a stock is ₹1,000 and does a 2-for-1 split, you now own two shares worth ₹500 each. The total value of your investment remains exactly the same.",
            "points": 50
        },
        {
            "date_string": "2026-05-29",
            "question": "What is the difference between 'Gross Income' and 'Net Income'?",
            "options": [
                "Gross is after taxes; Net is before taxes",
                "Gross is before taxes; Net is what actually hits your bank account",
                "They mean exactly the same thing"
            ],
            "correct_index": 1,
            "explanation": "Gross income is your total salary on paper. Net income is the painful reality of what you actually get to keep after income tax, healthcare, and deductions.",
            "points": 50
        },
        {
            "date_string": "2026-05-30",
            "question": "What is the fundamental concept of the 'Time Value of Money'?",
            "options": [
                "Money in your hand today is worth more than the exact same amount in the future",
                "Physical cash degrades over time",
                "You should only invest in companies that save time"
            ],
            "correct_index": 0,
            "explanation": "Because of inflation and the potential to earn interest, ₹1,000 today is much more powerful than receiving ₹1,000 five years from now.",
            "points": 50
        },
        {
            "date_string": "2026-05-31",
            "question": "What does a high P/E (Price-to-Earnings) Ratio generally indicate about a stock?",
            "options": [
                "The company is highly profitable and cheap to buy",
                "Investors expect high future growth, making the stock expensive relative to current profits",
                "The company is about to declare bankruptcy"
            ],
            "correct_index": 1,
            "explanation": "A high P/E ratio means you are paying a premium for every dollar the company earns right now, usually because the market believes the company will grow massively.",
            "points": 50
        }
]

# 3. The Upload Engine
print("Uploading Daily Quizzes to Firebase...")
collection_ref = db.collection('daily_quiz')

for quiz in quizzes:
    # We use the date string as the document ID so it's perfectly organized!
    doc_id = quiz['date_string']
    collection_ref.document(doc_id).set(quiz)
    print(f"✅ Uploaded Quiz for: {doc_id}")

print("All done! Your Quiz Engine is loaded and ready for Flutter.")