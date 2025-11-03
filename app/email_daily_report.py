import io
import base64
import requests
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from jinja2 import Template
from app.utils.charts import plot_current_month_chart, plot_current_week_chart
from app.utils.budget_utils import get_week_budget, get_month_budget
from app.utils.report_period import ReportPeriod
from datetime import date

# ================= CONFIG =================
SMTP_HOST = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_USER = "jeffcarbary@gmail.com"
SMTP_PASS = "REMOVED_SECRET"  # use app password or env var
TO_EMAIL = ["jeffcarbary@gmail.com", "deephousegenes@gmail.com"]

API_BASE = "http://localhost:5000/reports"

today = date.today()

# ================== FETCH DATA ==================
def fetch_report(endpoint):
    r = requests.get(f"{API_BASE}/{endpoint}")
    r.raise_for_status()
    return r.json()

week_data = fetch_report("week")
month_data = fetch_report("month")

# ================== WEEKLY CALC ==================
week_total = week_data["week_total"]
week_budget = week_data["week_budget"]
week_projected = week_data["week_projected"]
week_pct = week_data["week_pct"]
week_diff = week_data["week_diff"]
daily_totals = week_data["daily_totals"]
week_start = date.fromisoformat(week_data["week_start"])
week_end = date.fromisoformat(week_data["week_end"])
today = date.fromisoformat(week_data["today"]) 
num_week_days = week_data["num_week_days"]

# ================== MONTHLY CALC ==================
month_total = month_data["month_total"];
days_in_month = month_data["days_in_month"];
month_budget = month_data["month_budget"];
month_projected = month_data["month_projected"];
month_pct = month_data["month_pct"];
month_diff = month_data["month_diff"];
week_avg = month_data["week_avg"];
# ================== PLOT CHARTS ==================
week_chart_img = plot_current_week_chart(week_data.get("daily_totals", {}), week_start, num_week_days, today, week_budget)
month_chart_img = plot_current_month_chart(month_data.get("daily_totals", {}), today, days_in_month, month_budget)

# ================== EMAIL HTML ==================
html_template = """
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
</head>
<body>

<h3>Week Report</h3>
<p><strong>Total:</strong> ${{ week_total }}</p>
<p><strong>Pace:</strong> {{ week_pct }}% of ${{ week_budget }} — on pace for ${{ week_projected|round(0) }}
({{ '❌ $' ~ week_diff|round(0) ~ ' over' if week_diff>0 else '✅ $' ~ (-week_diff)|round(0) ~ ' under' }})</p>
<img src="cid:week_chart" width="600"/>

<h3>Month Report</h3>
<p><strong>Total:</strong> ${{ month_total }}</p>
<p><strong>Week Avg:</strong> ${{ week_avg|round(2) }}</p>
<p><strong>Pace:</strong> {{ month_pct }}% of ${{ month_budget }} — on pace for ${{ month_projected|round(0) }}
({{ '❌ $' ~ month_diff|round(0) ~ ' over' if month_diff>0 else '✅ $' ~ (-month_diff)|round(0) ~ ' under' }})</p>
<img src="cid:month_chart" width="600"/>
</body>
</html>
"""

html_content = Template(html_template).render(
    week_total=week_total,
    week_pct=week_pct,
    week_budget=week_budget,
    week_projected=week_projected,
    week_diff=week_diff,
    month_total=month_total,
    month_budget=month_budget,
    month_pct=month_pct,
    month_projected=month_projected,
    month_diff=month_diff,
    week_avg=week_avg
)

# ================== SEND EMAIL ==================
msg = MIMEMultipart('related')
msg['Subject'] = "📊 Daily Budget Report"
msg['From'] = SMTP_USER
msg['To'] = ", ".join(TO_EMAIL)

alt = MIMEMultipart('alternative')
msg.attach(alt)
alt.attach(MIMEText(html_content, 'html'))

# Attach charts
img_week = MIMEImage(base64.b64decode(week_chart_img))
img_week.add_header('Content-ID', '<week_chart>')
msg.attach(img_week)

img_month = MIMEImage(base64.b64decode(month_chart_img))
img_month.add_header('Content-ID', '<month_chart>')
msg.attach(img_month)

with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
    server.starttls()
    server.login(SMTP_USER, SMTP_PASS)
    server.sendmail(SMTP_USER, TO_EMAIL, msg.as_string())

print("✅ Email sent with inline charts successfully!")

