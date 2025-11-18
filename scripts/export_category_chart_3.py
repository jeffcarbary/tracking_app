import requests
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

from scripts.config import API_BASE_URL

API_URL = f"{API_BASE_URL}/transactions"

def plot_weekly_category_totals_api(category_name, start_date, end_date):
    # Request transactions from the API
    params = {
        "category": category_name,
        "start_date": start_date,
        "end_date": end_date
    }

    response = requests.get(API_URL, params=params)
    if response.status_code != 200:
        print(f"❌ API request failed: {response.status_code} {response.text}")
        return

    txns = response.json()
    if not txns:
        print(f"⚠️ No transactions found for '{category_name}' in that range.")
        return

    if isinstance(txns, dict) and "transactions" in txns:
        txns = txns["transactions"]

    # Convert string dates to datetime.date objects
    for txn in txns:
        txn["date"] = datetime.strptime(txn["date"], "%Y-%m-%d").date()

    # Group transactions by week
    weekly_sums = {}
    for txn in txns:
        week_start = txn["date"] - timedelta(days=txn["date"].weekday())
        weekly_sums[week_start] = weekly_sums.get(week_start, 0) + txn["amount"]

    sorted_weeks = sorted(weekly_sums.items())
    weeks = [w.strftime("%b %d") for w, _ in sorted_weeks]
    totals = [t for _, t in sorted_weeks]

    # Plot chart
    plt.figure(figsize=(8, 4))
    plt.bar(weeks, totals, color="#4C9AFF")
    plt.title(f"Weekly Totals for {category_name}")
    plt.xlabel("Week Starting")
    plt.ylabel("Amount ($)")
    plt.grid(axis="y", linestyle="--", alpha=0.6)
    plt.tight_layout()
    plt.show()

    print(f"✅ Charted {len(weeks)} weeks for {category_name} ({start_date}–{end_date})")


# Example usage
#plot_weekly_category_totals_api("Schoolcafe", "2025-07-01", "2025-10-31")
#plot_weekly_category_totals_api("Grocery", "2025-07-01", "2025-10-31")
plot_weekly_category_totals_api("Car", "2025-07-01", "2025-10-31")
