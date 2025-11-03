import io
import base64
from datetime import datetime, date, timedelta
import matplotlib.pyplot as plt

def plot_current_week_chart(daily_totals, week_start, num_days, today, weekly_budget):
    labels = [(week_start + timedelta(days=i)).strftime("%a %d") for i in range(num_days)]
    actual = []
    cumulative = 0
    days_so_far = 0
    for i in range(num_days):
        d = week_start + timedelta(days=i)
        daily_value = daily_totals.get(d.isoformat(), 0)

        if d <= today:
            # Skip plotting today if today's value is 0
            if d == today and daily_value == 0:
                actual.append(None)
                continue

            cumulative += daily_value
            days_so_far += 1
            actual.append(cumulative)
        else:
            actual.append(None)

    # Only average over days that have passed so far
    avg_daily = (cumulative / (days_so_far )) if days_so_far else 0
    projected = [avg_daily * (i + 1) for i in range(num_days)]
    budget_line = [weekly_budget] * num_days

    fig, ax = plt.subplots()
    ax.plot(labels, actual, label="Actual Spend", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Projected Spend", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_title("Week")
    ax.legend()
    buf = io.BytesIO()
    plt.savefig(buf, format="png")
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode("utf-8")

##def plot_current_week_chart(daily_totals, week_start, num_days, today, weekly_budget):
#    print('week start', week_start)
#    labels = [(week_start + timedelta(days=i)).strftime("%a %d") for i in range(num_days)]
#    actual = []
#    cumulative = 0
#    for i in range(num_days):
#        d = week_start + timedelta(days=i)
#        cumulative += daily_totals.get(d.isoformat(), 0)
#        actual.append(cumulative if d <= today else None)
#    avg_daily = cumulative / num_days if num_days else 0
#    projected = [avg_daily*(i+1) for i in range(num_days)]
#    budget_line = [weekly_budget]*num_days
#
#    fig, ax = plt.subplots()
#    ax.plot(labels, actual, label="Actual Spend", color="blue", linewidth=2)
#    ax.plot(labels, projected, label="Projected Spend", color="orange", linestyle="--")
#    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
#    ax.set_ylabel("Cumulative Spend ($)")
#    ax.set_title("Week")
#    ax.legend()
#    buf = io.BytesIO()
#    plt.savefig(buf, format="png")
#    plt.close(fig)
#    return base64.b64encode(buf.getvalue()).decode("utf-8")
#
def plot_current_month_chart(daily_totals, today, days_in_month, monthly_budget):
    days = [(today.replace(day=i+1)) for i in range(days_in_month)]
    labels = [d.day for d in days]
    cumulative = 0
    actual = []
    for d in days:
        daily_value = daily_totals.get(d.isoformat(), 0)

        if d <= today:
            # Skip plotting today's point if today's total is 0
            if d == today and daily_value == 0:
                actual.append(None)
                continue

            cumulative += daily_value
            actual.append(cumulative)
        else:
            actual.append(None)

    avg_daily = cumulative / (today.day - 1)  if today.day else 0
    projected = [avg_daily*(i+1) for i in range(days_in_month)]
    budget_line = [monthly_budget]*days_in_month

    fig, ax = plt.subplots(figsize=(10,8))
    ax.plot(labels, actual, label="Actual Spend", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Projected Spend", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_xlabel("Day of Month")
    ax.set_title("Month")
    ax.legend()
    buf = io.BytesIO()
    plt.savefig(buf, format="png")
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode("utf-8")

def plot_end_of_month_chart(daily_totals, month_start, month_end, monthly_budget):
    days_in_month = (month_end - month_start).days + 1
    labels = list(range(1, days_in_month + 1))
    actual = []
    cumulative = 0
    for i in range(days_in_month):
        d = month_start + timedelta(days=i)
        cumulative += daily_totals.get(d.isoformat(), 0)
        actual.append(cumulative)
    avg_daily = cumulative / days_in_month if days_in_month else 0
    budget_line = [monthly_budget] * days_in_month
    budget_daily = monthly_budget / days_in_month
    projected = [budget_daily * (i + 1) for i in range(days_in_month)]

    fig, ax = plt.subplots(figsize=(10, 8))
    ax.plot(labels, actual, label="Actual", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Budget", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_xlabel("Day of Month")
    ax.set_title(f"Monthly Report — {month_start.strftime('%B %Y')}")
    ax.legend()
    buf = io.BytesIO()
    plt.savefig(buf, format='png', transparent=False)
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode('utf-8')

def plot_category_pie(categories):
    """
    categories: list of dicts like:
        [{"name": "Restaurant", "amount": 120, "color": "#9ECAFF"}, ...]
    """
    labels = [c["name"] for c in categories]
    sizes = [c["total"] for c in categories]
    colors = [c["color"] for c in categories]


    fig, ax = plt.subplots(figsize=(24, 16))

    wedges, texts, autotexts = ax.pie(
        sizes,
        colors=colors,
        autopct=lambda p: f'{p:.1f}%' if p > 3 else '',  # show only >3%
        startangle=90,
        textprops={'fontsize': 20}
    )

    ax.axis('equal')  # keep circle

    # Legend with color-coded labels on the right
    ax.legend(
        wedges,
        labels,
        title=None,
        loc="center left",
        bbox_to_anchor=(0.9, 0, 0.3, 1),
        fontsize=24
    )

    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight', transparent=True)
    plt.close(fig)
    return base64.b64encode(buf.getvalue()).decode('utf-8')
