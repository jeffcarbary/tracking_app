#!/usr/local/bin/python3
import gspread
from google.oauth2.service_account import Credentials
from gspread.exceptions import WorksheetNotFound
from googleapiclient.discovery import build


# Define scopes for Google Sheets access
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]

# Path to your service account JSON
SERVICE_ACCOUNT_FILE = "/Users/jcarbary/stuff/flask_demo/app_new/secrets/western-replica-476202-t2-2876bb81a3f3.json"

# Sheet info
SHEET_URL = "https://docs.google.com/spreadsheets/d/1la40OxxRhXcuVNq1wJvXAf2iavlakyLswUPdyNCVLqY/edit?gid=891634794"

def get_gsheet(worksheet_name="Sheet1"):
    """Authenticate and return a gspread worksheet object."""
    creds = Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )
    client = gspread.authorize(creds)
    spreadsheet = client.open_by_url(SHEET_URL)
    return spreadsheet.worksheet(worksheet_name)

def get_or_create_gsheet(name):
    """Authenticate and return a gspread worksheet object."""
    creds = Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )
    client = gspread.authorize(creds)
    spreadsheet = client.open_by_url(SHEET_URL)
    try:
        return spreadsheet.worksheet(name)
    except WorksheetNotFound:
        return spreadsheet.add_worksheet(title=name, rows=400, cols=4, index=1)

def get_service():
    """Authenticate and return a Google Sheets API service client."""
    creds = Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )
    service = build("sheets", "v4", credentials=creds)
    return service

def get_sheets():
    """Return both gspread client and spreadsheet objects."""
    creds = Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=SCOPES
    )
    client = gspread.authorize(creds)
    spreadsheet = client.open_by_url(SHEET_URL)
    return client, spreadsheet

