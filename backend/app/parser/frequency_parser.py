"""
frequency_parser.py

Converts prescription frequency text into
standard Morning-Afternoon-Night format.
"""


def parse_frequency(text: str) -> str:

    t = text.upper().strip()

    # Already formatted
    if "-" in t:
        return t

    # Once Daily
    if "OD" in t:
        return "1-0-0"

    # Twice Daily
    if "BD" in t:
        return "1-0-1"

    # Three Times Daily
    if "TDS" in t or "TID" in t:
        return "1-1-1"

    # Four Times Daily
    if "QID" in t:
        return "1-1-1-1"

    # At Night
    if "HS" in t:
        return "0-0-1"

    # SOS
    if "SOS" in t:
        return "SOS"

    morning = "MORNING" in t
    afternoon = "AFTERNOON" in t
    night = "NIGHT" in t

    if morning and afternoon and night:
        return "1-1-1"

    if morning and night:
        return "1-0-1"

    if morning:
        return "1-0-0"

    if afternoon:
        return "0-1-0"

    if night:
        return "0-0-1"

    return ""