#!/usr/local/bin/python3
from datetime import datetime, timedelta
import pandas as pd
from scripts.export_transactions_to_sheets import export_transactions, populate_sheet, static_setup, clear_sheet
import sys
# ------------------------
# CONFIG
# ------------------------
YEAR = 2025
MONTH = 11
BASE_TAB_NAME = f"November2025"


def month_weeks_friday_to_thursday(month: int, year: int):
    """Return list of (start_date, end_date) tuples covering the full month in Friday→Thursday weeks,
    including days before the first Friday.
    """
    first_day = datetime(year, month, 1).date()
    last_day = pd.Timestamp(first_day).replace(day=pd.Timestamp(first_day).days_in_month).date()

    weeks = []

    # First partial week (before first Friday)
    first_friday = first_day + timedelta((4 - first_day.weekday()) % 7)  # Friday=4
    if first_friday > first_day:
        first_thursday = first_friday - timedelta(days=1)
        weeks.append((first_day, first_thursday))

    # Remaining Friday→Thursday weeks
    current_start = first_friday
    while current_start <= last_day:
        current_end = current_start + timedelta(days=6)
        if current_end > last_day:
            current_end = last_day
        weeks.append((current_start, current_end))
        current_start = current_end + timedelta(days=1)

    return weeks


# ------------------------
# RUN EXPORTS
# ------------------------
weeks = month_weeks_friday_to_thursday(MONTH, YEAR)
clear_sheet(
    tab_name = BASE_TAB_NAME
)
static_setup(
    tab_name = BASE_TAB_NAME
)
for week_index, (start_date, end_date) in enumerate(weeks):
    start_col = (week_index * 4) + 4  # 4 columns per week
    #clear_sheet = True if week_index == 0 else False  # only clear on first week
    clear_sheet = False

    grand_total = export_transactions(
        start_date=str(start_date),
        end_date=str(end_date),
        tab_name=BASE_TAB_NAME,
        start_col=start_col,
        clear_sheet=clear_sheet,
        week_index=week_index
    )
    populate_sheet(
        start_date=str(start_date),
        end_date=str(end_date),
        tab_name=BASE_TAB_NAME,
        week_index=week_index,
        grand_total=grand_total
    )
#    sys.exit()

    print(f"✅ Exported week {week_index+1}: {start_date} → {end_date} at columns starting {start_col}")

