#!/usr/local/bin/python3
import requests
from datetime import date
from scripts.config import API_BASE_URL

BASE_URL = f"{API_BASE_URL}/transactions"

def prompt_post():
    print("Add a new transaction")
    
    description = input("Enter description: ").strip()
    amount = input("Enter amount: ").strip()
    category = input("Enter category: ").strip()
    date_input = input("Enter date (YYYY-MM-DD, leave blank for today): ").strip()
    
    # Use current date if blank
    if not date_input:
        date_input = str(date.today())
    
    # Validate amount
    try:
        amount = float(amount)
    except ValueError:
        print("Amount must be a number.")
        return
    
    data = {
        "description": description,
        "amount": amount,
        "category": category,
        "date": date_input
    }
    
    # Send POST request
    try:
        response = requests.post(BASE_URL, json=data, timeout=5)
        response.raise_for_status()
        print("Transaction added successfully:")
        print(response.json())
    except requests.exceptions.RequestException as e:
        print("Error adding transaction:", e)

if __name__ == "__main__":
    prompt_post()

