from flask import Blueprint, render_template, request, redirect, url_for, abort, jsonify, flash
from .models import LogEntry, FoodItem, User
from app.extensions import db
from datetime import datetime, timedelta, time, date
from zoneinfo import ZoneInfo
from calendar import monthrange

import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

nutrition_bp = Blueprint(
    "nutrition",
    __name__,
    url_prefix="/<username>/nutrition",
    static_folder="static", 
    template_folder="templates"
)

def get_user(username):
    user = User.query.filter_by(username=username).first()
    if not user:
        abort(404, description=f"User '{username}' not found")
    return user


#helper for charts
def build_metric_series(entries, times, now_rounded, start, end, goal, attr):
    # ---- Actual cumulative ----
    actual = []
    current_total = 0
    for t in times:
        if t <= now_rounded:
            current_total = sum(getattr(e, attr) for e in entries if e.timestamp <= t)
            actual.append(round(current_total, 1))

    # ---- Target line (straight) ----
    total_seconds = (end - start).total_seconds()
    target = []
    current_target = 0
    for t in times:
        elapsed = (t - start).total_seconds()
        tgt = (elapsed / total_seconds) * goal
        t_val = round(tgt, 1)
        target.append(t_val)

        if t <= now_rounded:
            current_target = t_val

    # ---- Projection ----
    first_time = start
    elapsed_seconds = (now_rounded - first_time).total_seconds()
    pace = current_total / elapsed_seconds if elapsed_seconds > 0 else 0

    projected = []
    for t in times:
        elapsed = (t - first_time).total_seconds()
        projected.append(round(max(0, pace * elapsed), 1))

    # ---- Target catch-up time ----
    if current_target - current_total < 0:  # ahead of target
        if goal > 0:  # avoid division by zero
            target_pace = goal / total_seconds  # calories/sec (or protein/fiber)
            seconds_to_reach_current = current_total / target_pace
            target_catchup_time = start + timedelta(seconds=seconds_to_reach_current)
        else:
            target_catchup_time = None
    else:
        target_catchup_time = None

    return {
        "actual": actual,
        "target": target,
        "projected": projected,
        "current_total": round(current_total),
        "current_target": round(current_target),
        "current_deficit": round(current_target - current_total),
        "target_catchup_time": target_catchup_time,
        "goal": round(goal)
    }

@nutrition_bp.route("/", methods=["GET"])
def index(username):
    user = get_user(username)

    chicago_tz = ZoneInfo("America/Chicago")
    today = datetime.now(chicago_tz).date()
    now = datetime.now(chicago_tz).replace(tzinfo=None)
    # Round 'now' to the next 15-minute interval
    minute = (now.minute // 15 + 1) * 15
    hour = now.hour
    if minute == 60:
        minute = 0
        hour += 1
    now_rounded = now.replace(hour=hour, minute=minute, second=0, microsecond=0)

    # Window (naive to match DB)
    start = datetime.combine(today, user.day_start_time) - timedelta(hours=1)
    end = datetime.combine(today, user.day_end_time) + timedelta(hours=1)

    logger.info("Fetching entries from %s to %s", start, end)

    # Fetch entries
    entries = (
        LogEntry.query.filter(
            LogEntry.user_id == user.id,
            LogEntry.timestamp >= start,
            LogEntry.timestamp <= end
        )
        .order_by(LogEntry.timestamp)
        .all()
    )

    for e in entries:
        logger.info("Entry: %s calories=%s", e.timestamp, e.calories)

    # Time axis (15-min increments)
    interval = timedelta(minutes=15)
    times = []
    current = start
    while current <= end:
        times.append(current)
        current += interval

    # Actual cumulative calories
    cal = build_metric_series(entries, times, now_rounded, start, end, user.calorie_goal or 0, "calories")
    pro = build_metric_series(entries, times, now_rounded, start, end, user.protein_goal or 0, "protein")
    fib = build_metric_series(entries, times, now_rounded, start, end, user.fiber_goal or 0, "fiber")
   
    return render_template(
        "nutrition/index.html",
        user=user,
        entries=entries[-10:],
        chart_labels=[t.strftime("%H:%M") for t in times],
        calories=cal,
        protein=pro,
        fiber=fib
    )




@nutrition_bp.route("/add_entry", methods=["GET", "POST"])
def add_entry(username):
    user = get_user(username)
    food_items = FoodItem.query.order_by(FoodItem.name).all()

    # Previous entries (unique by food)
    previous_entries_all = LogEntry.query.filter_by(user_id=user.id).order_by(LogEntry.timestamp.desc()).all()
    seen_foods = set()
    previous_entries = []
    for e in previous_entries_all:
        if e.food.name not in seen_foods:
            previous_entries.append(e)
            seen_foods.add(e.food.name)
    previous_entries = previous_entries[:20]

    if request.method == "POST":
        food_name = request.form["food_name"].strip()
        amount = float(request.form["amount"])
        unit = request.form.get("unit", "g")
        calories = float(request.form.get("calories", 0))
        protein = float(request.form.get("protein", 0))
        fiber = float(request.form.get("fiber", 0))
        date_str = request.form.get("date")
        time_str = request.form.get("time")

        chicago_tz = ZoneInfo("America/Chicago")

        # Handle optional date/time
        if not date_str:
            date_part = datetime.now(chicago_tz).date()
        else:
            date_part = datetime.strptime(date_str, "%Y-%m-%d").date()
        
        if not time_str:
            time_part = datetime.now(chicago_tz).time()
        else:
            time_part = datetime.strptime(time_str, "%H:%M").time()
        
        timestamp = datetime.combine(date_part, time_part)

        # Find or create food
        food = FoodItem.query.filter_by(name=food_name).first()
        if not food:
            food = FoodItem(name=food_name, base_amount=100, calories=calories, protein=protein, fiber=fiber)
            db.session.add(food)
            db.session.commit()

        # Create log entry
        entry = LogEntry(
            user_id=user.id,
            food_id=food.id,
            amount=amount,
            unit=unit,
            calories=calories,
            protein=protein,
            fiber=fiber,
            timestamp=timestamp
        )
        db.session.add(entry)
        db.session.commit()
        return redirect(url_for("nutrition.index", username=username))

    return render_template(
        "nutrition/add_entry.html",
        user=user,
        food_items=food_items,
        previous_entries=previous_entries
    )


@nutrition_bp.route("/previous_entries", methods=["GET"])
def get_previous_entries(username):
    user = get_user(username)
    entries_all = LogEntry.query.filter_by(user_id=user.id).order_by(LogEntry.timestamp.desc()).all()
    seen_foods = set()
    entries = []
    for e in entries_all:
        if e.food.name not in seen_foods:
            entries.append(e)
            seen_foods.add(e.food.name)
    entries = entries[:20]

    result = [
        {
            "id": e.id,
            "food_name": e.food.name,
            "amount": e.amount,
            "unit": e.unit,
            "calories": e.calories,
            "protein": e.protein,
            "fiber": e.fiber
        }
        for e in entries
    ]
    return jsonify(result)

@nutrition_bp.route("/delete_entries", methods=["GET", "POST"])
def delete_entries(username):
    user = get_user(username)
    chicago_tz = ZoneInfo("America/Chicago")

    # Determine the day to show
    if request.method == "POST":
        date_str = request.form.get("date")
        if date_str:
            day = datetime.strptime(date_str, "%Y-%m-%d").date()
        else:
            day = datetime.now(chicago_tz).date()
    else:
        day = datetime.now(chicago_tz).date()

    # Window for the day
    start = datetime.combine(day, user.day_start_time)
    end = datetime.combine(day, user.day_end_time)

    # Fetch entries for that day
    entries = (
        LogEntry.query.filter(
            LogEntry.user_id == user.id,
            LogEntry.timestamp >= start,
            LogEntry.timestamp <= end
        )
        .order_by(LogEntry.timestamp)
        .all()
    )

    return render_template(
        "nutrition/delete_entries.html",
        user=user,
        entries=entries,
        day=day
    )

@nutrition_bp.route("/delete_entry/<int:entry_id>", methods=["POST"])
def delete_entry(username, entry_id):
    user = get_user(username)
    entry = LogEntry.query.filter_by(id=entry_id, user_id=user.id).first_or_404()
    db.session.delete(entry)
    db.session.commit()
    return redirect(url_for("nutrition.delete_entries", username=username))

@nutrition_bp.route("/edit_entry/<int:entry_id>", methods=["GET", "POST"])
def edit_entry(username, entry_id):
    user = get_user(username)
    entry = LogEntry.query.get_or_404(entry_id)

    # Ensure entry belongs to this user
    if entry.user_id != user.id:
        abort(403)

    if request.method == "POST":
        # Update entry from form
        entry.amount = float(request.form["amount"])
        entry.unit = request.form.get("unit", entry.unit)
        entry.calories = float(request.form.get("calories", entry.calories))
        entry.protein = float(request.form.get("protein", entry.protein))
        entry.fiber = float(request.form.get("fiber", entry.fiber))
        db.session.commit()
        return redirect(url_for("nutrition.delete_entries", username=username))

    return render_template(
        "nutrition/edit_entry.html",
        user=user,
        entry=entry
    )

@nutrition_bp.route("/settings", methods=["GET", "POST"])
def settings(username):
    user = get_user(username)

    def to_int(value):
        try:
            return int(round(float(value)))
        except (TypeError, ValueError):
            return None

    if request.method == "POST":
        # Convert goals safely
        user.calorie_goal = to_int(request.form.get("calorie_goal"))
        user.protein_goal = to_int(request.form.get("protein_goal"))
        user.fiber_goal = to_int(request.form.get("fiber_goal"))

        # Example: also update day start/end
        user.day_start_time = request.form.get("day_start_time")
        user.day_end_time = request.form.get("day_end_time")

        db.session.commit()
        flash("Settings updated!", "success")
        return redirect(url_for("nutrition.settings", username=username))

    return render_template("nutrition/settings.html", user=user)

@nutrition_bp.route("/month_view", methods=["GET", "POST"])
def month_view(username):
    from calendar import monthrange

    user = get_user(username)

    chicago_tz = ZoneInfo("America/Chicago")
    today = datetime.now(chicago_tz).date()

    # Default to current month
    month_str = request.form.get("month") if request.method == "POST" else today.strftime("%Y-%m")
    year, month = map(int, month_str.split("-"))
    start_date = datetime(year, month, 1)
    end_date = datetime(year, month, monthrange(year, month)[1], 23, 59, 59)

    # Fetch entries for the month
    entries = LogEntry.query.filter(
        LogEntry.user_id == user.id,
        LogEntry.timestamp >= start_date,
        LogEntry.timestamp <= end_date
    ).all()

    # Group entries by day
    entries_by_day = {}
    for e in entries:
        day = e.timestamp.date()
        entries_by_day.setdefault(day, []).append(e)

    # Prepare chart data
    chart_labels = []
    cal_data = []
    pro_data = []
    fib_data = []

    daily_cal_totals = []
    daily_pro_totals = []
    daily_fib_totals = []

    for day_num in range(1, monthrange(year, month)[1] + 1):
        day_date = datetime(year, month, day_num).date()
        chart_labels.append(day_date.strftime("%b %d"))
        day_entries = entries_by_day.get(day_date, [])

        cal_total = sum(e.calories for e in day_entries)
        pro_total = sum(e.protein for e in day_entries)
        fib_total = sum(e.fiber for e in day_entries)

        cal_data.append(cal_total)
        pro_data.append(pro_total)
        fib_data.append(fib_total)

        if day_entries:
            daily_cal_totals.append(cal_total)
            daily_pro_totals.append(pro_total)
            daily_fib_totals.append(fib_total)

    # Averages (only include days with data)
    cal_avg = round(sum(daily_cal_totals)/len(daily_cal_totals), 1) if daily_cal_totals else 0
    pro_avg = round(sum(daily_pro_totals)/len(daily_pro_totals), 1) if daily_pro_totals else 0
    fib_avg = round(sum(daily_fib_totals)/len(daily_fib_totals), 1) if daily_fib_totals else 0

    return render_template(
        "nutrition/month_view.html",
        user=user,
        chart_labels=chart_labels,
        cal_data=cal_data,
        pro_data=pro_data,
        fib_data=fib_data,
        cal_goal=user.calorie_goal,
        pro_goal=user.protein_goal,
        fib_goal=user.fiber_goal,
        cal_avg=cal_avg,
        pro_avg=pro_avg,
        fib_avg=fib_avg,
        month_str=month_str
    )


@nutrition_bp.route("/week", methods=["GET"])
def week_report(username):
    if current_user.username != username:
        abort(403)

    user = current_user

    # Parse week selection from query ?week=YYYY-WW
    selected = request.args.get("week")

    today = datetime.date.today()
    iso_year, iso_week, _ = today.isocalendar()

    if selected:
        try:
            y, w = selected.split("-")
            iso_year = int(y)
            iso_week = int(w)
        except:
            pass

    # Get Monday of selected ISO week
    start = datetime.date.fromisocalendar(iso_year, iso_week, 1)
    end = start + datetime.timedelta(days=6)

    # Query entries
    entries = (
        Entry.query.filter(
            Entry.user_id == user.id,
            Entry.timestamp >= datetime.datetime.combine(start, datetime.time.min),
            Entry.timestamp <= datetime.datetime.combine(end, datetime.time.max),
        ).all()
    )

    # Build day buckets
    day_map = { (start + datetime.timedelta(days=i)): {"cal":0,"pro":0,"fib":0, "has":False} for i in range(7) }

    for e in entries:
        d = e.timestamp.date()
        if d in day_map:
            day_map[d]["cal"] += e.calories
            day_map[d]["pro"] += e.protein
            day_map[d]["fib"] += e.fiber
            day_map[d]["has"] = True

    # Prepare chart lists in weekday order
    labels = [d.strftime("%a %d") for d in day_map.keys()]
    calories = [day_map[d]["cal"] for d in day_map.keys()]
    protein = [day_map[d]["pro"] for d in day_map.keys()]
    fiber = [day_map[d]["fib"] for d in day_map.keys()]

    # Averages (only days with data)
    days_with_data = [d for d in day_map.values() if d["has"]]
    avg_cal = sum(d["cal"] for d in days_with_data) / len(days_with_data) if days_with_data else 0
    avg_pro = sum(d["pro"] for d in days_with_data) / len(days_with_data) if days_with_data else 0
    avg_fib = sum(d["fib"] for d in days_with_data) / len(days_with_data) if days_with_data else 0

    return render_template(
        "week.html",
        labels=labels,
        calories=calories,
        protein=protein,
        fiber=fiber,
        start=start,
        end=end,
        iso_year=iso_year,
        iso_week=iso_week,
        avg_cal=avg_cal,
        avg_pro=avg_pro,
        avg_fib=avg_fib,
        user=user,
    )

@nutrition_bp.route("/reports", methods=["GET"])
def reports(username):
    """
    Unified reports page: weekly + monthly.
    Query params (optional):
      - week=YYYY-Www   (e.g. 2025-W46)  -> ISO week format used by <input type="week">
      - month=YYYY-MM   (e.g. 2025-11)   -> used by <input type="month">
    """
    user = get_user(username)

    # timezone and today
    chicago_tz = ZoneInfo("America/Chicago")
    today = datetime.now(chicago_tz).date()

    # ----- WEEK data -----
    # week selector format from query arg (e.g. "2025-W46" or "2025-46")
    week_param = request.args.get("week")
    if week_param:
        # normalize "YYYY-Www" or "YYYY-Www" -> year, week
        # input type="week" produces "YYYY-Www" (e.g. "2025-W46")
        try:
            if "-W" in week_param:
                y, w = week_param.split("-W")
            elif "-" in week_param:
                y, w = week_param.split("-")
            else:
                y, w = week_param.split("-")
            iso_year = int(y)
            iso_week = int(w)
        except Exception:
            iso_year, iso_week = today.isocalendar()[0], today.isocalendar()[1]
    else:
        iso_year, iso_week = today.isocalendar()[0], today.isocalendar()[1]

    # monday..sunday for that ISO week
    week_start_date = date.fromisocalendar(iso_year, iso_week, 1)
    week_end_date = week_start_date + timedelta(days=6)
    # full datetime bounds
    week_start_dt = datetime.combine(week_start_date, time.min)
    week_end_dt = datetime.combine(week_end_date, time.max)

    week_entries = (
        LogEntry.query.filter(
            LogEntry.user_id == user.id,
            LogEntry.timestamp >= week_start_dt,
            LogEntry.timestamp <= week_end_dt
        )
        .order_by(LogEntry.timestamp)
        .all()
    )

    # bucket by day
    week_labels = []
    week_cal = []
    week_pro = []
    week_fib = []
    week_daily_with_data_cal = []
    week_daily_with_data_pro = []
    week_daily_with_data_fib = []

    for i in range(7):
        d = week_start_date + timedelta(days=i)
        week_labels.append(d.strftime("%a %d"))
        day_entries = [e for e in week_entries if e.timestamp.date() == d]
        cal_sum = sum(e.calories for e in day_entries)
        pro_sum = sum(e.protein for e in day_entries)
        fib_sum = sum(e.fiber for e in day_entries)

        week_cal.append(cal_sum)
        week_pro.append(pro_sum)
        week_fib.append(fib_sum)

        if day_entries:
            week_daily_with_data_cal.append(cal_sum)
            week_daily_with_data_pro.append(pro_sum)
            week_daily_with_data_fib.append(fib_sum)

    week_avg_cal = round(sum(week_daily_with_data_cal) / len(week_daily_with_data_cal), 1) if week_daily_with_data_cal else 0
    week_avg_pro = round(sum(week_daily_with_data_pro) / len(week_daily_with_data_pro), 1) if week_daily_with_data_pro else 0
    week_avg_fib = round(sum(week_daily_with_data_fib) / len(week_daily_with_data_fib), 1) if week_daily_with_data_fib else 0

    # daily goal lines (per day)
    week_goal_cal_line = [user.calorie_goal] * 7
    week_goal_pro_line = [user.protein_goal] * 7
    week_goal_fib_line = [user.fiber_goal] * 7

    # ----- MONTH data -----
    month_param = request.args.get("month")  # "YYYY-MM"
    if month_param:
        try:
            y, m = map(int, month_param.split("-"))
            month_year = y
            month_month = m
        except Exception:
            month_year = today.year
            month_month = today.month
    else:
        month_year = today.year
        month_month = today.month

    # compute days in month
    last_day = monthrange(month_year, month_month)[1]
    month_start_date = date(month_year, month_month, 1)
    month_end_date = date(month_year, month_month, last_day)
    month_start_dt = datetime.combine(month_start_date, time.min)
    month_end_dt = datetime.combine(month_end_date, time.max)

    month_entries = (
        LogEntry.query.filter(
            LogEntry.user_id == user.id,
            LogEntry.timestamp >= month_start_dt,
            LogEntry.timestamp <= month_end_dt
        )
        .order_by(LogEntry.timestamp)
        .all()
    )

    month_labels = []
    month_cal = []
    month_pro = []
    month_fib = []
    month_daily_with_data_cal = []
    month_daily_with_data_pro = []
    month_daily_with_data_fib = []

    for day_num in range(1, last_day + 1):
        d = date(month_year, month_month, day_num)
        month_labels.append(d.strftime("%b %d"))
        day_entries = [e for e in month_entries if e.timestamp.date() == d]
        cal_sum = sum(e.calories for e in day_entries)
        pro_sum = sum(e.protein for e in day_entries)
        fib_sum = sum(e.fiber for e in day_entries)

        month_cal.append(cal_sum)
        month_pro.append(pro_sum)
        month_fib.append(fib_sum)

        if day_entries:
            month_daily_with_data_cal.append(cal_sum)
            month_daily_with_data_pro.append(pro_sum)
            month_daily_with_data_fib.append(fib_sum)

    month_avg_cal = round(sum(month_daily_with_data_cal) / len(month_daily_with_data_cal), 1) if month_daily_with_data_cal else 0
    month_avg_pro = round(sum(month_daily_with_data_pro) / len(month_daily_with_data_pro), 1) if month_daily_with_data_pro else 0
    month_avg_fib = round(sum(month_daily_with_data_fib) / len(month_daily_with_data_fib), 1) if month_daily_with_data_fib else 0

    month_goal_cal_line = [user.calorie_goal] * len(month_labels)
    month_goal_pro_line = [user.protein_goal] * len(month_labels)
    month_goal_fib_line = [user.fiber_goal] * len(month_labels)

    # pass all data to template
    return render_template(
        "nutrition/reports.html",
        user=user,

        # week
        week_labels=week_labels,
        week_cal=week_cal,
        week_pro=week_pro,
        week_fib=week_fib,
        week_goal_cal_line=week_goal_cal_line,
        week_goal_pro_line=week_goal_pro_line,
        week_goal_fib_line=week_goal_fib_line,
        week_avg_cal=week_avg_cal,
        week_avg_pro=week_avg_pro,
        week_avg_fib=week_avg_fib,
        selected_week=f"{iso_year}-W{iso_week:02d}",

        # month
        month_labels=month_labels,
        month_cal=month_cal,
        month_pro=month_pro,
        month_fib=month_fib,
        month_goal_cal_line=month_goal_cal_line,
        month_goal_pro_line=month_goal_pro_line,
        month_goal_fib_line=month_goal_fib_line,
        month_avg_cal=month_avg_cal,
        month_avg_pro=month_avg_pro,
        month_avg_fib=month_avg_fib,
        selected_month=f"{month_year:04d}-{month_month:02d}"
    )

