#!/usr/local/bin/python3
from datetime import date
from scripts.export_transactions_to_sheets import export_transactions
#from export_transactions_to_sheets import export_transactions
import calendar

start_date_str = ""
end_date_str = ""
start_col=1
BASE_TAB_NAME="All_Trans"

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
