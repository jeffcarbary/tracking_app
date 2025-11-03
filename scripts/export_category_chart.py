import requests
from collections import defaultdict
from decimal import Decimal
import matplotlib.pyplot as plt

from scripts.config import API_BASE_URL


def export_category_chart(category, start_date, end_date):
    """
    Fetch transactions for a given category and date range, then make a pie chart.
    """
    API_URL = f"{API_BASE_URL}/transactions"
    params = {
        "start_date": start_date,
        "end_date": end_date,
        "category": category
    }

    # Fetch data
    response = requests.get(API_URL, params=params)
    response.raise_for_status()
    data = response.json()
    transactions = data.get("transactions", [])
    transactions = [t for t in transactions if t["category"]["name"].lower() == category.lower()]

    if not transactions:
        print("No transactions found for this category/date range.")
        return

    # Sum amounts by subcategory or description
    sums = defaultdict(Decimal)
    for t in transactions:
        key = t.get("subcategory") or t.get("description")  # adjust if you have subcategories
        sums[key] += Decimal(str(t["amount"]))

    labels = list(sums.keys())
    values = [float(v) for v in sums.values()]

    # Make pie chart
    plt.figure(figsize=(8,8))
    plt.pie(values, labels=labels, autopct="%1.1f%%", startangle=90)
    plt.title(f"{category} transactions: {start_date} → {end_date}")
    plt.axis("equal")  # equal aspect ratio ensures pie is circular
    plt.show()

    # Optional: save to file
    # plt.savefig(f"{category}_{start_date}_to_{end_date}.png")

# Example usage
export_category_chart("Schoolcafe", "2025-07-01", "2025-10-31")
