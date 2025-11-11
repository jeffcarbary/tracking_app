import io
import base64
from datetime import datetime, date, timedelta
import matplotlib.pyplot as plt

def plot_current_week_chart(daily_totals, week_start, num_days, today, weekly_budget):
    # --- Build dates and labels ---
    start_day = week_start - timedelta(days=1)  # baseline day for (0,0)
    days = [start_day] + [week_start + timedelta(days=i) for i in range(num_days)]
    labels = [0] + [(week_start + timedelta(days=i)).strftime("%a %d") for i in range(num_days)]

    # --- Build cumulative actuals ---
    cumulative = 0
    actual = [0]  # start at (0,0)
    days_so_far = 0

    for d in days[1:]:
        daily_value = daily_totals.get(d.isoformat(), 0)
        if d <= today:
            if d == today and daily_value == 0:
                actual.append(None)
                continue
            cumulative += daily_value
            days_so_far += 1
            actual.append(cumulative)
        else:
            actual.append(None)

    # --- Compute projection ---
    avg_daily = (cumulative / days_so_far) if days_so_far else 0
    projected = [0] + [avg_daily * (i + 1) for i in range(num_days)]

    # --- Budget line stays constant (not starting at 0) ---
    budget_line = [weekly_budget] * (num_days + 1)

    # --- Create figure ---
    fig, ax = plt.subplots(figsize=(8, 5))

    # --- Plot lines ---
    ax.plot(labels, actual, label="Actual Spend", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Budget", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")

    # --- Labels and title ---
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_xlabel("Day of Week")
    ax.set_title(f"Weekly Spending ({week_start.strftime('%b %d')} - "
                 f"{(week_start + timedelta(days=num_days-1)).strftime('%b %d')})")

    # --- Y-axis and layout ---
    ymax = max((max(projected) if projected else 0), weekly_budget) * 1.1
    ax.set_ylim(0, ymax)
    ax.set_aspect('auto', adjustable='datalim')
    ax.grid(True, linestyle='--', alpha=0.6)
    ax.legend()

    fig.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format="png", bbox_inches='tight')
    plt.close(fig)

    return base64.b64encode(buf.getvalue()).decode("utf-8")
    # Set consistent Y range
    ax.set_ylim(0, weekly_budget * 1.1)

    # Let Matplotlib auto-manage aspect ratio (don’t force equal)
    ax.set_aspect('auto', adjustable='datalim')

    # Grid and legend
    ax.grid(True, linestyle='--', alpha=0.6)
    ax.legend()

    # Layout and save
    fig.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format="png", bbox_inches='tight')
    plt.close(fig)

    return base64.b64encode(buf.getvalue()).decode("utf-8")

def plot_current_month_chart(daily_totals, today, days_in_month, monthly_budget):
    # --- Build date list with a day 0 baseline ---
    start_day = today.replace(day=1) - timedelta(days=1)
    days = [start_day] + [(today.replace(day=i+1)) for i in range(days_in_month)]
    labels = [0] + [d.day for d in days[1:]]  # "0" marks the starting point

    # --- Build cumulative actuals ---
    cumulative = 0
    actual = [0]  # start at (0, 0)
    for d in days[1:]:
        daily_value = daily_totals.get(d.isoformat(), 0)
        if d <= today:
            if d == today and daily_value == 0:
                actual.append(None)
                continue
            cumulative += daily_value
            actual.append(cumulative)
        else:
            actual.append(None)

    # --- Compute projection ---
    days_so_far = max(today.day - 1, 1)
    avg_daily = cumulative / days_so_far
    projected = [0] + [avg_daily * (i + 1) for i in range(days_in_month)]
    budget_line = [monthly_budget] + [monthly_budget] * days_in_month

    # --- Plot setup ---
    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(labels, actual, label="Actual Spend", color="blue", linewidth=2)
    ax.plot(labels, projected, label="Projected Spend", color="orange", linestyle="--")
    ax.plot(labels, budget_line, label="Budget", color="red", linestyle=":")

    # Labels and title
    ax.set_ylabel("Cumulative Spend ($)")
    ax.set_xlabel("Day of Month")
    ax.set_title(f"{today.strftime('%B %Y')} Spending Progress")

    # --- Scale and grid ---
    ymax = max((max(projected) if projected else 0), monthly_budget) * 1.1
    ax.set_ylim(0, ymax)
    ax.set_aspect('auto', adjustable='datalim')
    ax.grid(True, linestyle='--', alpha=0.6)
    ax.legend()

    # --- Layout and export ---
    fig.tight_layout()
    buf = io.BytesIO()
    plt.savefig(buf, format="png", bbox_inches='tight')
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
