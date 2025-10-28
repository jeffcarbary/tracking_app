#!/usr/local/bin/python3
import requests

url = "http://127.0.0.1:5000/transactions"

# Test GET first
try:
    resp = requests.get(url, timeout=5)  # Add timeout to avoid hanging
    print("GET /transactions:", resp.status_code, resp.json())
except requests.exceptions.RequestException as e:
    print("Error:", e)

# Test POST
data = {
    "description": "Groceries",
    "amount": -50,
    "category": "Food",
    "date": "2025-10-24"
}

try:
    resp = requests.post(url, json=data, timeout=5)
    print("POST /transactions:", resp.status_code, resp.json())
except requests.exceptions.RequestException as e:
    print("Error:", e)

