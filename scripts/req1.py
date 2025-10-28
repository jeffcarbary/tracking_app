#!/usr/local/bin/python3
import requests

url = "http://127.0.0.1:5000/transactions"
data = {
    "description": "Groceries",
    "amount": -50,
    "category": "Food",
    "date": "2025-10-24"
}

resp = requests.post(url, json=data)
print(resp.status_code, resp.json())
