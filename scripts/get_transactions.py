#!/usr/local/bin/python3
import requests
import sys

from scripts.config import API_BASE_URL
BASE_URL = f"{API_BASE_URL}/transactions"
YEAR = "2025"

def get_transactions_by_date():
    # Check command-line arguments
    start_date = sys.argv[1] if len(sys.argv) > 1 else None
    end_date = sys.argv[2] if len(sys.argv) > 2 else None

    # Prompt if missing
    if not start_date:
        start_date = input(f"Enter start date ({YEAR}) (MM-DD): ").strip()
    if not end_date:
        end_date = input(f"Enter end date ({YEAR}) (MM-DD): ").strip()

    if not start_date or not end_date:
        params = {}
    else:
        start_date = f"{YEAR}-{start_date}" 
        end_date   = f"{YEAR}-{end_date}" 
        params = {"start_date": start_date, "end_date": end_date}

    # Send GET request with query parameters
    try:
        response = requests.get(BASE_URL, params=params, timeout=5)
        response.raise_for_status()
        if response.status_code == 200:
            data = response.json()
            transactions = data["transactions"]
            total_amount = data["total_amount"]

            print(f"Total amount: {total_amount}")
            for t in transactions:
                print(f"{t['date']} | {t['description']} | {t['amount']} | {t['category']}")
        else:
            print(f"Error fetching transactions: {response.status_code} - {response.text}")

    except requests.exceptions.RequestException as e:
        print("Error fetching transactions:", e)


if __name__ == "__main__":
    get_transactions_by_date()

