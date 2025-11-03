from datetime import date, timedelta, datetime
import calendar

class ReportPeriod:
    def __init__(self, today=None):
        self.today = today or date.today()

    def week_range(self) -> tuple[date, date]:
        # most recent Friday
        offset = (self.today.weekday() - 4) % 7
        week_start = self.today - timedelta(days=offset)
        week_end = week_start + timedelta(days=6)

        # Clip to month
        first_of_month = self.today.replace(day=1)
        last_of_month = (first_of_month.replace(day=28) + timedelta(days=4)).replace(day=1) - timedelta(days=1)
        if week_start < first_of_month:
            week_start = first_of_month
        if week_end > last_of_month:
            week_end = last_of_month

        return week_start, week_end

    def month_range(self):
        """Return the start and end date of the month."""
        start = self.today.replace(day=1)
        next_month = (start.replace(day=28) + timedelta(days=4)).replace(day=1)
        end = next_month - timedelta(days=1)
        return start, end

    def num_days(self, start, end):
        return (end - start).days + 1

    def day_of_week(self):
        """Return name of today’s day, e.g., 'Friday'."""
        return self.today.strftime("%A")
