#!/usr/local/bin/python3
import requests
from scripts.google_config import get_gsheet
from scripts.config import API_BASE_URL


# ------------------------
# CONFIG
# ------------------------
API_URL = f"{API_BASE_URL}/transactions"

WORKSHEET_NAME = "Sheet1"

# ------------------------
# GET SHEET DATA
# ------------------------
sheet = get_gsheet(WORKSHEET_NAME)
all_values = sheet.get_all_records()  # returns list of dicts

# Example format of each row: {'Date': '2025-10-01', 'Description': 'Grocery', 'Category': 'Food', 'Amount': 45.25}
# ------------------------
# HELPER FUNCTION
# ------------------------
def clean_amount(value):
    """Convert a string like '$1,234.56' to float 1234.56"""
    #if value is None:
    #    return 0.0
    if isinstance(value, (int, float)):
        return float(value)
    # Remove $ and commas
    cleaned = str(value).replace("$", "").replace(",", "").strip()
    try:
        return float(cleaned)
    except ValueError:
        return None

# ------------------------
# SEND TO API
# ------------------------
for row in all_values:
    # Clean amount
    amount = clean_amount(row.get("Amount"))

    # Build payload matching your Flask Transaction model
    payload = {
        "date": row.get("Date"),
        "description": row.get("Description"),
        "category": row.get("Category", "Misc"), 
        "amount": amount
    }
    try:
        response = requests.post(API_URL, json=payload)
        response.raise_for_status()
        
        data = response.json()  # decode JSON response from API
    
        if data.get("message") == "Duplicate transaction exists":
            print(f"⚠️ Duplicate transaction skipped: {payload} (existing ID: {data.get('id')})")
        else:
            print(f"✅ Created transaction: {payload} (ID: {data.get('transaction_id')})")
    
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to post transaction {payload}: {e}")
        if e.response is not None:
            print("Server response:", e.response.text)
