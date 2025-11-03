from datetime import timedelta

def get_week_budget(num_days):
    """
    Returns prorated weekly budget.
    Full week = $800.
    Partial weeks = $100/day.
    """
    return 800 if num_days == 7 else 100 * num_days


def get_month_budget(date_obj):
    """
    Returns monthly budget based on the number of days in the month.
    Base: $800/week for 4 weeks (28 days).
    Add $100 for each extra day beyond 28.
    """
    next_month = (date_obj.replace(day=28) + timedelta(days=4)).replace(day=1)
    days_in_month = (next_month - timedelta(days=1)).day
    return 800 * 4 + 100 * (days_in_month - 28)
