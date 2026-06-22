"""
Helpers for building weekly schedule grid views.
"""

# Days and time slots used across the weekly timetable
SCHEDULE_DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
TIME_SLOTS = [
    ("08:00", "10:00"),
    ("10:00", "12:00"),
    ("13:00", "15:00"),
    ("15:00", "17:00"),
]


def normalize_time(time_str):
    """Normalize time to HH:MM for consistent grid matching."""
    if not time_str:
        return time_str
    return time_str[:5]


def build_weekly_grid(schedules):
    """
    Build a weekly timetable grid from schedule records.
    Returns (grid, days, time_slots) where grid[day][(start, end)] = class info dict or None.
    """
    grid = {day: {(start, end): None for start, end in TIME_SLOTS} for day in SCHEDULE_DAYS}

    for schedule in schedules:
        day = schedule.day
        start = normalize_time(schedule.start_time)
        end = normalize_time(schedule.end_time)
        slot = (start, end)

        if day not in grid:
            continue

        cell = {
            "subject": schedule.subject.subject_name,
            "subject_code": schedule.subject.subject_code,
            "professor": schedule.professor.full_name,
            "room": schedule.room,
            "section": schedule.section,
            "year_level": schedule.year_level,
            "time_label": f"{start} - {end}",
        }

        if slot in grid[day] and grid[day][slot] is None:
            grid[day][slot] = cell
        else:
            # Stack extra classes in the same slot (professor with multiple sections)
            existing = grid[day].get(slot)
            if existing is None:
                grid[day][slot] = cell
            elif isinstance(existing, list):
                existing.append(cell)
            else:
                grid[day][slot] = [existing, cell]

    return grid, SCHEDULE_DAYS, TIME_SLOTS
