# --- Configuration ---

import datetime
import io
import base64
import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from jinja2 import Template
import matplotlib.pyplot as plt
from email.mime.image import MIMEImage

# ===================== CONFIG =====================
SMTP_HOST = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_USER = "jeffcarbary@gmail.com"
SMTP_PASS = "REMOVED_SECRET"  # use app password or env var
TO_EMAIL = ["jeffcarbary@gmail.com", "raquelcarbary@gmail.com"] 

API_BASE = "http://localhost:5000/reports"  # change if remote

# ===================== DATE CONTROL =====================
NOW = datetime.date.today()
today = NOW

# ===================== BUDGET LOGIC =====================
def get_weekly_budget(today_date):
    weekday = today_date.weekday()  # Mon=0 .. Sun=6
    friday_weekday = 4
    diff_to_fri = weekday - friday_weekday if weekday >= 4 else weekday + 3
    week_start = today_date - datetime.timedelta(days=diff_to_fri)
    week_end = week_start + datetime.timedelta(days=6)

    # Month boundaries
    first_of_month = today_date.replace(day=1)
    last_of_month = (today_date.replace(day=1) + datetime.timedelta(days=32)).replace(day=1) - datetime.timedelta(days=1)

    if week_start < first_of_month:
        week_start = first_of_month
    if week_end > last_of_month:
        week_end = last_of_month

    num_days = (week_end - week_start).days + 1
    budget = 800 if num_days == 7 else 100 * num_days
    return budget, week_start, week_end

def get_monthly_budget(today_date):
    days_in_month = (today_date.replace(day=1) + datetime.timedelta(days=32)).replace(day=1) - datetime.timedelta(days=1)
    days_in_month = days_in_month.day
    return 800*4 + 100*(days_in_month - 28)

# ===================== FETCH DATA =====================
def fetch_report(endpoint):
    res = requests.get(f"{API_BASE}/{endpoint}")
    res.raise_for_status()
    return res.json()

weekly_data = fetch_report("weekly")
monthly_data = fetch_report("monthly")

# ===================== CALCULATE WEEKLY =====================
weekly_budget, week_start, week_end = get_weekly_budget(today)
daily_totals = weekly_data.get("daily_totals", {})
days_so_far = (today - week_start).days + 1
weekly_total = sum(daily_totals.get((week_start + datetime.timedelta(days=i)).isoformat(), 0)
                   for i in range((week_end - week_start).days + 1))
weekly_projected = (weekly_total / days_so_far) * 7 if days_so_far else 0
weekly_pct = round((weekly_projected / weekly_budget) * 100, 1)
weekly_diff = weekly_projected - weekly_budget

# ===================== CALCULATE MONTHLY =====================
monthly_budget = get_monthly_budget(today)
daily_totals_month = monthly_data.get("daily_totals", {})
monthly_total = sum(daily_totals_month.get((today.replace(day=d)).isoformat(), 0)
                    for d in range(1, today.day+1))
days_in_month = (today.replace(day=1) + datetime.timedelta(days=32)).replace(day=1) - datetime.timedelta(days=1)
days_in_month = days_in_month.day
monthly_projected = (monthly_total / today.day) * days_in_month if today.day else 0
monthly_pct = round((monthly_projected / monthly_budget) * 100, 1)
monthly_diff = monthly_projected - monthly_budget
weekly_avg = (monthly_projected / days_in_month) * 7

# ===================== GENERATE CHARTS =====================
def plot_weekly_chart(daily_totals, week_start, today, weekly_budget):
    labels = ['Fri','Sat','Sun','Mon','Tue','Wed','Thu']
    actual = []
    cumulative = 0
    for i in range(7):
        d = week_start + datetime.timedelta(days=i)
        cumulative += daily_totals.get(d.isoformat(), 0)
        actual.append(cumulative if d <= today else None)
    days_so_far = sum(1 for v in actual if v is not None)
    avg_daily = cumulative / days_so_far if days_so_far else 0
    projected = [avg_daily * (i+1) for i in range(7)]
    budget_line = [weekly_budget]*7

    fig, ax = plt.subplots()
    ax.plot(labels, actual, label="Actual", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Projected", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_title("Week Report")
    ax.legend()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode('utf-8')

def plot_monthly_chart(daily_totals, today, monthly_budget):
    days_in_month = (today.replace(day=1) + datetime.timedelta(days=32)).replace(day=1) - datetime.timedelta(days=1)
    days_in_month = days_in_month.day
    labels = list(range(1, days_in_month+1))
    actual = []
    cumulative = 0
    for i in range(1, days_in_month+1):
        d = today.replace(day=i)
        cumulative += daily_totals.get(d.isoformat(), 0)
        actual.append(cumulative if d <= today else None)
    avg_daily = cumulative / today.day if today.day else 0
    projected = [avg_daily*(i+1) for i in range(days_in_month)]
    budget_line = [monthly_budget]*days_in_month

    fig, ax = plt.subplots(figsize=(10,4))
    ax.plot(labels, actual, label="Actual", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Projected", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_xlabel("Day of Month")
    ax.set_title("Monthly Report")
    ax.legend()
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode('utf-8')

weekly_chart_img = plot_weekly_chart(daily_totals, week_start, today, weekly_budget)
monthly_chart_img = plot_monthly_chart(daily_totals_month, today, monthly_budget)

# ===================== HTML TEMPLATE =====================
html_template = """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>📊 Budget Reports</title>
</head>
<body>
  <h2>📅 Week & Monthly Reports</h2>

  <h3>Week Report</h3>
  <p><strong>Total:</strong> ${{ weekly_total }}</p>
  <p><strong>Pace:</strong> {{ weekly_pct }}% of ${{ weekly_budget }} — on pace for ${{ weekly_projected|round(0) }} ({{ '❌ $' ~ weekly_diff|round(0) ~ ' over' if weekly_diff>0 else '✅ $' ~ (-weekly_diff)|round(0) ~ ' under' }})</p>
  <img src="data:image/png;base64,{{ weekly_chart }}" width="600"/>

  <h3>Monthly Report</h3>
  <p><strong>Total:</strong> ${{ monthly_total }}</p>
  <p><strong>Week Avg:</strong> ${{ weekly_avg|round(2) }}</p>
  <p><strong>Pace:</strong> {{ monthly_pct }}% of ${{ monthly_budget }} — on pace for ${{ monthly_projected|round(0) }} ({{ '❌ $' ~ monthly_diff|round(0) ~ ' over' if monthly_diff>0 else '✅ $' ~ (-monthly_diff)|round(0) ~ ' under' }})</p>
  <img src="data:image/png;base64,{{ monthly_chart }}" width="600"/>
</body>
</html>
"""

html_content = Template(html_template).render(
    weekly_total=weekly_total,
    weekly_pct=weekly_pct,
    weekly_budget=weekly_budget,
    weekly_projected=weekly_projected,
    weekly_diff=weekly_diff,
    monthly_total=monthly_total,
    monthly_budget=monthly_budget,
    monthly_pct=monthly_pct,
    monthly_projected=monthly_projected,
    monthly_diff=monthly_diff,
    weekly_avg=weekly_avg,
    weekly_chart=weekly_chart_img,
    monthly_chart=monthly_chart_img
)

# ===================== SEND EMAIL (CID ATTACHMENT FIX) =====================
msg = MIMEMultipart('related')
msg['Subject'] = "📊 Budget Report"
msg['From'] = SMTP_USER
msg['To'] = ", ".join(TO_EMAIL) 

# Create alternative MIME part (for HTML)
msg_alt = MIMEMultipart('alternative')
msg.attach(msg_alt)

# Add HTML using CID references for inline images
html_content = Template(html_template.replace(
    'data:image/png;base64,{{ weekly_chart }}', 'cid:weekly_chart'
).replace(
    'data:image/png;base64,{{ monthly_chart }}', 'cid:monthly_chart'
)).render(
    weekly_total=weekly_total,
    weekly_pct=weekly_pct,
    weekly_budget=weekly_budget,
    weekly_projected=weekly_projected,
    weekly_diff=weekly_diff,
    monthly_total=monthly_total,
    monthly_budget=monthly_budget,
    monthly_pct=monthly_pct,
    monthly_projected=monthly_projected,
    monthly_diff=monthly_diff,
    weekly_avg=weekly_avg,
    weekly_chart='cid:weekly_chart',
    monthly_chart='cid:monthly_chart'
)
msg_alt.attach(MIMEText(html_content, 'html'))

# Attach weekly chart
img_weekly = MIMEImage(base64.b64decode(weekly_chart_img))
img_weekly.add_header('Content-ID', '<weekly_chart>')
msg.attach(img_weekly)

# Attach monthly chart
img_monthly = MIMEImage(base64.b64decode(monthly_chart_img))
img_monthly.add_header('Content-ID', '<monthly_chart>')
msg.attach(img_monthly)

# Send via SMTP
with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
    server.starttls()
    server.login(SMTP_USER, SMTP_PASS)
#    server.send_message(msg)
    server.sendmail(SMTP_USER, TO_EMAIL, msg.as_string()) #for list of emails

print("✅ Email sent with inline charts successfully!")

