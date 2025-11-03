#!/usr/local/bin/python3

import sys
import requests
from collections import defaultdict
from decimal import Decimal
import colorsys
import string
from datetime import datetime
from scripts.google_config import get_or_create_gsheet, get_service, get_sheets
from gspread.utils import rowcol_to_a1

from scripts.config import API_BASE_URL

# ------------------------
# HELPERS
# ------------------------

def ensure_columns(sheet, total_cols_needed):
    """Add columns if the sheet doesn't have enough."""
    current_cols = sheet.col_count
    if current_cols < total_cols_needed:
        sheet.add_cols(total_cols_needed - current_cols)

def generate_unique_color(existing_colors, index):
    """Generate a visually distinct color"""
    h = index / max(1, len(existing_colors) + 5)
    r, g, b = colorsys.hsv_to_rgb(h, 0.5, 1.0)
    hex_color = '#{:02X}{:02X}{:02X}'.format(int(r * 255), int(g * 255), int(b * 255))
    while hex_color in existing_colors:
        h += 0.05
        if h > 1:
            h -= 1
        r, g, b = colorsys.hsv_to_rgb(h, 0.5, 1.0)
        hex_color = '#{:02X}{:02X}{:02X}'.format(int(r * 255), int(g * 255), int(b * 255))
    return hex_color

def hex_to_rgb_float(hex_color):
    """Convert #RRGGBB → float RGB dict"""
    hex_color = hex_color.lstrip("#")
    r = int(hex_color[0:2], 16) / 255
    g = int(hex_color[2:4], 16) / 255
    b = int(hex_color[4:6], 16) / 255
    return {"red": r, "green": g, "blue": b}

def clear_sheet(tab_name):
    sheet = get_or_create_gsheet(tab_name)
    sheet.clear()

    # Clear all formatting
    sheet.spreadsheet.batch_update({
        "requests": [
            {
                "repeatCell": {
                    "range": {"sheetId": sheet.id},
                    "cell": {"userEnteredFormat": {}},
                    "fields": "*"
                }
            }
        ]
    })


    
def static_setup(tab_name):
    
    # Get gspread sheet object (destination tab)
    sheet = get_or_create_gsheet(tab_name)
    
    # Google Sheets API client (for batch updates and formatting)
    service = get_service()
    _, spreadsheet = get_sheets()
    spreadsheet_id = spreadsheet.id
    
    # Get the source and destination sheet IDs
    source_sheet = spreadsheet.worksheet("Month_Template")
    destination_sheet = spreadsheet.worksheet(tab_name)
    
    # Copy columns A–D (0–4) with formatting from Month_Template → October2025
    copy_request = {
        "requests": [
            {
                "copyPaste": {
                    "source": {
                        "sheetId": source_sheet.id,
                        "startRowIndex": 0,
                        "endRowIndex": 400,      # adjust as needed
                        "startColumnIndex": 0,   # column A
                        "endColumnIndex": 4,     # column D (exclusive)
                    },
                    "destination": {
                        "sheetId": destination_sheet.id,
                        "startRowIndex": 0,
                        "startColumnIndex": 0,   # paste at column A
                        "endColumnIndex": 4,
                    },
                    "pasteType": "PASTE_NORMAL",       # includes formatting
                    "pasteOrientation": "NORMAL",
                }
            }
        ]
    }
    
    # Execute copy-paste
    service.spreadsheets().batchUpdate(
        spreadsheetId=spreadsheet_id,
        body=copy_request
    ).execute()
    
    destination_sheet.update("A1", [[tab_name]])
    print(f"✅ Copied columns A–D (with formatting) from Month_Template → {tab_name}")


    #source_sheet = get_or_create_gsheet("Month_Template")
    #dest_sheet = get_or_create_gsheet(tab_name)
    #data = source_sheet.get("A:D")
    #dest_sheet.batch_clear(["A:D"])
    #dest_sheet.update("A1", data, value_input_option="USER_ENTERED")
    #dest_sheet.update("A24", [["Total:"]])
    #formula = "=SUM(B16:B21)"
    #dest_sheet.update("B24", [[formula]], value_input_option="USER_ENTERED")
    #formula = "=SUM(C16:C21)"
    #dest_sheet.update("C24", [[formula]], value_input_option="USER_ENTERED")
    
def populate_sheet(
    start_date, 
    end_date,
    tab_name,
    week_index,
    grand_total
):
    starting_row = 16
    sheet = get_or_create_gsheet(tab_name)

    # Determine target row and values
    row_num = week_index + starting_row
    num_days = (datetime.strptime(end_date, "%Y-%m-%d") - datetime.strptime(start_date, "%Y-%m-%d")).days + 1
    val = 800 if num_days == 7 else 100 * num_days
    val_c = grand_total if grand_total else val

    # Build the A1 range for A–C
    start_col = 1  # column A
    end_col = 3    # column C
    range_a1 = f"{rowcol_to_a1(row_num, start_col).split(':')[0]}:{rowcol_to_a1(row_num, end_col).split(':')[0]}"

    # Prepare data row
    values = [[f"{start_date} - {end_date}", val, val_c]]

    # Perform a single batch update
    sheet.update(range_a1, values)

    # Bold the date range cell (column A)
    date_cell = rowcol_to_a1(row_num, 1)
    sheet.format(date_cell, {"textFormat": {"bold": True}})

    print(f"✅ Updated {range_a1} with {values}")
        
        
        
        

    
    
# ------------------------
# MAIN EXPORT FUNCTION
# ------------------------

def export_transactions(
    start_date,
    end_date,
    tab_name,
    start_col=0,       # NEW: starting column for writing data (0 = A)
    clear_sheet=True,   # NEW: whether to clear existing sheet before writing
    week_index=0,
    sort_transactions=True
):
    """Fetch transactions, summarize by category, and export to Google Sheets"""

    BASE_URL = f"{API_BASE_URL}/api/transactions"
    params = {"start_date": start_date, "end_date": end_date}

    # ------------------------
    # FETCH TRANSACTIONS
    # ------------------------
    response = requests.get(BASE_URL, params=params)
    response.raise_for_status()
    data = response.json()
    transactions = data.get("transactions", data if isinstance(data, list) else [])

    # ------------------------
    # SUM BY CATEGORY
    # ------------------------
    category_sums = defaultdict(Decimal)
    category_colors = {}

    for t in transactions:
        cat_name = t["category"]["name"]
        category_sums[cat_name] += Decimal(str(t["amount"]))
        if cat_name not in category_colors:
            category_colors[cat_name] = t["category"]["color"]

    category_rows = [
        [cat, float(total)]
        for cat, total in sorted(category_sums.items(), key=lambda x: x[1], reverse=True)
    ]

    # ------------------------
    # WRITE TO GOOGLE SHEETS
    # ------------------------
    sheet = get_or_create_gsheet(tab_name)

  
    num_columns_needed = start_col + 4 
    ensure_columns(sheet, num_columns_needed)

    col_letters = [
    rowcol_to_a1(1, start_col + i + 1)[:-1]  # e.g. start_col=27 → "AB"
    for i in range(4)
    ]
    # ------------------------
    # HEADERS
    # ------------------------
    headers = ["Date", "Description", "Category", "Amount"]
    header_range = f"{col_letters[0]}1:{col_letters[-1]}1"
    sheet.update(header_range, [headers])  # 1 row x 4 cols

    start_data_row = 2
    # ------------------------
    # TRANSACTIONS
    # ------------------------
    if sort_transactions:
        transactions_sorted = sorted(transactions, key=lambda t: t["amount"], reverse=True)
    else:
        transactions_sorted = sorted(transactions, key=lambda t: t["date"], reverse=True)
    # Write each row starting at row 2
    if transactions_sorted:
        rows_data = [
            [t["date"], t["description"], t["category"]["name"], float(t["amount"])]
            for t in transactions_sorted
        ]
        num_rows = len(rows_data)
        data_range = f"{col_letters[0]}2:{col_letters[-1]}{1 + num_rows}"
        sheet.update(data_range, rows_data)  # batch update
    else:
        return

    # ------------------------
    # CATEGORY TOTALS
    # ------------------------
    #HEADERS
    start_category_row = start_data_row + len(rows_data) + 1
    cat_col_letters = [string.ascii_uppercase[start_col + i] for i in range(2)]
    header_range = f"{cat_col_letters[0]}{start_category_row}:{cat_col_letters[1]}{start_category_row}"
    sheet.update(header_range, [["Category", "Total Amount"]])
    #DATA
    category_data_start_row = start_category_row + 1
    category_rows_data = [[cat, float(total)] for cat, total in sorted(category_sums.items(), key=lambda x: x[1], reverse=True)]
    num_category_rows = len(category_rows_data)
    data_range = f"{cat_col_letters[0]}{category_data_start_row}:{cat_col_letters[-1]}{category_data_start_row + num_category_rows - 1}"
    sheet.update(data_range, category_rows_data)
    end_category_row = start_category_row + len(category_rows_data)

    

    # GRAND TOTAL
    sheet.append_row([])
    grand_total_row = end_category_row + 1
    grand_total = float(sum(category_sums.values()))
    sheet.update_cell(grand_total_row, start_col + 1, "Grand Total")  
    sheet.update_cell(grand_total_row, start_col + 2, grand_total )

    # ------------------------
    # FORMAT SHEET
    # ------------------------
    sheet_id = sheet.id
    requests_list = []

    # Header formatting (bold + light blue)
    requests_list.append({
        "repeatCell": {
            "range": {"sheetId": sheet_id, "startRowIndex": 0, "endRowIndex": 1},
            "cell": {
                "userEnteredFormat": {
                    "backgroundColor": {"red": 0.8, "green": 0.9, "blue": 1.0},
                    "textFormat": {"bold": True}
                }
            },
            "fields": "userEnteredFormat(backgroundColor,textFormat)"
        }
    })

    # Grand total formatting (bold + green)
    requests_list.append({
        "repeatCell": {
            "range": {
                "sheetId": sheet_id,
                "startRowIndex": grand_total_row - 1,
                "endRowIndex": grand_total_row,
                "startColumnIndex": start_col,
                "endColumnIndex": start_col + 4
            },
            "cell": {
                "userEnteredFormat": {
                    "backgroundColor": {"red": 0.6, "green": 1.0, "blue": 0.6},
                    "textFormat": {"bold": True}
                }
            },
            "fields": "userEnteredFormat(backgroundColor,textFormat)"
        }
    })

    # Category totals coloring (columns A+B)
    for idx, (cat_name, total) in enumerate(category_rows):
        color_rgb = hex_to_rgb_float(category_colors.get(cat_name, "#CCCCCC"))
        row_index = start_category_row  + idx
        requests_list.append({
            "repeatCell": {
                "range": {
                    "sheetId": sheet_id,
                    "startRowIndex": row_index,
                    "endRowIndex": row_index + 1,
                    "startColumnIndex": start_col,
                    "endColumnIndex": start_col + 2
                },
                "cell": {
                    "userEnteredFormat": {
                        "backgroundColor": color_rgb,
                        "textFormat": {"bold": True}
                    }
                },
                "fields": "userEnteredFormat(backgroundColor,textFormat)"
            }
        })

    # Transaction row coloring (columns A–D)
    for idx, t in enumerate(transactions_sorted):
        cat_name = t["category"]["name"]
        color_rgb = hex_to_rgb_float(category_colors.get(cat_name, "#CCCCCC"))
        row_index = start_data_row - 1 + idx
        requests_list.append({
            "repeatCell": {
                "range": {
                    "sheetId": sheet_id,
                    "startRowIndex": row_index,
                    "endRowIndex": row_index + 1,
                    "startColumnIndex": start_col,
                    "endColumnIndex": start_col + 4
                },
                "cell": {"userEnteredFormat": {"backgroundColor": color_rgb}},
                "fields": "userEnteredFormat(backgroundColor)"
            }
        })

    # Apply all formatting
    sheet.spreadsheet.batch_update({"requests": requests_list})

    print(f"✅ Export complete for tab '{tab_name}'!")
    return grand_total


# ------------------------
# CLI ENTRY POINT
# ------------------------
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <YYYY-MM-DD> <YYYY-MM-DD> (optional: SheetName)")
        sys.exit(1)

    start_date, end_date = sys.argv[1], sys.argv[2]
    tab_name = sys.argv[3] if len(sys.argv) == 4 else "Sheet1"

    export_transactions(start_date, end_date, tab_name)

