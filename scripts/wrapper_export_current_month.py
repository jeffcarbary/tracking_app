#!/usr/local/bin/python3
from datetime import date
from scripts.export_transactions_to_sheets import export_transactions
#from export_transactions_to_sheets import export_transactions
import calendar

BASE_TAB_NAME="Current_Month"
start_col=1
# ------------------------
# Get current month start and end dates
# ------------------------
today = date.today()
start_date = today.replace(day=1)  # first day of current month
last_day = calendar.monthrange(today.year, today.month)[1]
end_date = today.replace(day=last_day)  # last day of current month

# Convert to strings if export_transactions expects strings
start_date_str = start_date.isoformat()  # "YYYY-MM-DD"
end_date_str = end_date.isoformat()

# ------------------------
# Call export_transactions
# ------------------------
grand_total = export_transactions(
    start_date=start_date_str,
    end_date=end_date_str,
    tab_name=BASE_TAB_NAME,
    start_col=start_col,
    sort_transactions=False
)
