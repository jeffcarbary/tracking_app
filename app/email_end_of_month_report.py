# ===================== MONTHLY REPORT EMAIL WITH WEEKLY TOTALS + TRANSACTIONS =====================
import datetime
import io
import base64
import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from jinja2 import Template
from  app.utils.charts import plot_end_of_month_chart, plot_category_pie
from scripts.config import API_BASE_URL

# ===================== CONFIG =====================
SMTP_HOST = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_USER = "jeffcarbary@gmail.com"
SMTP_PASS = "REMOVED_SECRET"  # use app password or env var
TO_EMAIL = ["jeffcarbary@gmail.com", "deephousegenes@gmail.com"]
#TO_EMAIL = ["jeffcarbary@gmail.com", "raquelcarbary@gmail.com"]

API_BASE = API_BASE_URL  # base for API endpoints

# ===================== SELECT MONTH HERE =====================
REPORT_MONTH = datetime.date(2025, 11, 1)

month_start = REPORT_MONTH.replace(day=1)
next_month = (month_start.replace(day=28) + datetime.timedelta(days=4)).replace(day=1)
month_end = next_month - datetime.timedelta(days=1)

# ===================== BUDGET LOGIC =====================
def get_month_budget(date_ref):
    days_in_month = (month_end - month_start).days + 1
    return 800 * 4 + 100 * (days_in_month - 28)

month_budget = get_month_budget(month_end)

# ===================== FETCH DATA =====================
def fetch_report(endpoint, override_date=None):
    params = {}
    if override_date:
        params["today"] = override_date.strftime("%Y-%m-%d")
    res = requests.get(f"{API_BASE}/reports/{endpoint}", params=params)
    res.raise_for_status()
    return res.json()

def fetch_transactions(start_date, end_date):
    url = f"{API_BASE}/api/transactions"
    params = {"start_date": start_date.isoformat(), "end_date": end_date.isoformat()}
    res = requests.get(url, params=params)

    #print("STATUS:", res.status_code)
    #print("TEXT:", res.text[:500])  # show first 500 chars to see if it's HTML or empty

    res.raise_for_status()  # will raise an error for 4xx/5xx responses
    data = res.json()  # returns {"transactions": [...], "total_amount": ...}
    transactions = data.get("transactions", [])
    return transactions

month_data = fetch_report("month", override_date=month_end)
transactions = fetch_transactions(month_start, month_end)

# ===================== CALCULATE MONTHLY METRICS =====================
daily_totals = month_data.get("daily_totals", {})
days_in_month = (month_end - month_start).days + 1
month_total = sum(
    daily_totals.get((month_start + datetime.timedelta(days=i)).isoformat(), 0)
    for i in range(days_in_month)
)
avg_daily = month_total / days_in_month if days_in_month else 0
month_projected = avg_daily * days_in_month
month_pct = round((month_projected / month_budget) * 100, 1)
month_diff = month_projected - month_budget
week_avg = avg_daily * 7

# ===================== WEEKLY TOTALS (Fri → Thu) =====================

def calculate_week_totals(daily_totals, month_start, month_end):
    week_totals = []
    current_start = month_start

    while current_start <= month_end:
        weekday = current_start.weekday()  # Mon=0..Sun=6
        days_to_thursday = (3 - weekday) % 7  # Thursday is 3
        week_end = current_start + datetime.timedelta(days=days_to_thursday)
        if week_end > month_end:
            week_end = month_end

        week_total = sum(
            daily_totals.get((current_start + datetime.timedelta(days=i)).isoformat(), 0)
            for i in range((week_end - current_start).days + 1)
        )

        week_totals.append({
            "week_start": current_start,
            "week_end": week_end,
            "total": week_total
        })

        current_start = week_end + datetime.timedelta(days=1)

    return week_totals

week_totals = calculate_week_totals(daily_totals, month_start, month_end)

# Summarize by category
category_totals = []
for t in transactions:
    found = next((c for c in category_totals if c["name"] == t["category"]["name"]), None)
    if found:
        found["total"] += t["amount"]
    else:
        category_totals.append({
            "name": t["category"]["name"],
            "total": t["amount"],
            "color": t["category"]["color"]
        })
category_totals_sorted = sorted(category_totals, key=lambda x: x["total"], reverse=True)

# ===================== MONTHLY CHART =====================
#moved to charts.py
month_chart_img = plot_end_of_month_chart(daily_totals, month_start, month_end, month_budget)

# ===================== CATEGORY PIE CHART =====================
category_pie_img = plot_category_pie(category_totals_sorted)

# ===================== HTML TEMPLATE =====================
html_template='''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>📊 Monthly Budget Report</title>
  <style>
    body { font-family: Arial, sans-serif; font-size: 14px; }
    h2, h3 { margin-bottom: 6px; }
    table { border-collapse: collapse; margin-bottom: 12px; font-size: 13px; width: auto; }
    th, td { border: 1px solid #ccc; padding: 2px 6px; text-align: left; white-space: nowrap; }
    th { background-color: #f2f2f2; }
  </style>
</head>
<body>
  <h2>📅 Monthly Budget Report — {{ month_name }}</h2>
  <p><strong>Total:</strong> ${{ month_total|round(2) }}</p>
  <p><strong>Weekly Avg:</strong> ${{ week_avg|round(2) }}</p>
  <p><strong>Budget:</strong> {{ month_pct }}% of ${{ month_budget }}
    ({{ '❌ $' ~ month_diff|round(0) ~ ' over' if month_diff>0 else '✅ $' ~ (-month_diff)|round(0) ~ ' under' }})
  </p>

  <img src="cid:month_chart" width="700"/>

  <h3>🗓 Weekly Totals (Fri → Thu)</h3>
  <table>
    <tr>
      <th>Week Start</th>
      <th>Week End</th>
      <th>Total</th>
    </tr>
    {% for w in week_totals %}
    <tr>
      <td>{{ w.week_start.strftime("%Y-%m-%d") }}</td>
      <td>{{ w.week_end.strftime("%Y-%m-%d") }}</td>
      <td>${{ w.total|round(2) }}</td>
    </tr>
    {% endfor %}
  </table>

    <h3>💸 Category Summary</h3>
  <div style="display: flex; align-items: flex-start; gap: 20px;">
    <!-- Category table -->
    <table style="border-collapse: collapse; font-size: 14px; text-align: left;">
      <tr>
        <th style="padding: 2px 6px;">Category</th>
        <th style="padding: 2px 6px;">Total</th>
      </tr>
      {% for c in category_totals %}
      <tr style="background-color: {{ c.color }}; font-weight: bold;">
        <td style="padding: 2px 6px;">{{ c.name }}</td>
        <td style="padding: 2px 6px;">${{ c.total|round(2) }}</td>
      </tr>
      {% endfor %}
    </table>
  
    <!-- Pie chart -->
    <img src="cid:category_pie" width="600" height="400" style="border: none;"/>
  </div>
  <h3>💸 Transactions</h3>
    <table>
      <tr>
        <th>Date</th>
        <th>Description</th>
        <th>Category</th>
        <th>Amount</th>
      </tr>
      {% for t in transactions %}
      <tr style="background-color: {{ t.category.color }};">  <!-- very light color -->
        <td>{{ t.date }}</td>
        <td>{{ t.description }}</td>
        <td>{{ t.category.name }}</td>
        <td>${{ t.amount|round(2) }}</td>
      </tr>
      {% endfor %}
    </table>
'''

# Sort transactions by date (newest first)
transactions_sorted = sorted(transactions, key=lambda t: t["amount"], reverse=True)

html_content = Template(html_template).render(
    month_name=month_start.strftime("%B %Y"),
    month_total=month_total,
    month_budget=month_budget,
    month_pct=month_pct,
    month_diff=month_diff,
    week_avg=week_avg,
    week_totals=week_totals,
    transactions=transactions_sorted,
    category_totals=category_totals_sorted
)

# ===================== SEND EMAIL =====================
msg = MIMEMultipart('related')
msg['Subject'] = f"📊 End of Month Budget Report — {month_start.strftime('%B %Y')}"
msg['From'] = SMTP_USER
msg['To'] = ", ".join(TO_EMAIL)

msg_alt = MIMEMultipart('alternative')
msg.attach(msg_alt)
msg_alt.attach(MIMEText(html_content, 'html'))

img_monthly = MIMEImage(base64.b64decode(month_chart_img))
img_monthly.add_header('Content-ID', '<month_chart>')
msg.attach(img_monthly)

img_category = MIMEImage(base64.b64decode(category_pie_img))
img_category.add_header('Content-ID', '<category_pie>')
msg.attach(img_category)

with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
    server.starttls()
    server.login(SMTP_USER, SMTP_PASS)
    server.sendmail(SMTP_USER, TO_EMAIL, msg.as_string())

print(f"✅ Monthly report email sent for {month_start.strftime('%B %Y')}!")
