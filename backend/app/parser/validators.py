from app.parser.constants import *
import re


def is_medicine_line(text: str):

    text = text.strip().upper()

    # Ignore quantity lines like (Tot:8 Tab)
    if re.match(r"^\(TOT\s*:", text):
        return False

    # Remove OCR junk like ), *, 1., 3, -, etc.
    cleaned = re.sub(r'^[^A-Z]+', '', text)

    # Existing prefixes
    if any(cleaned.startswith(prefix) for prefix in MEDICINE_PREFIXES):
        return True

    # Handle lines like "3 CAP. ZOCLAR 500"
    if re.search(r'\b(TAB|TAB\.|CAP|CAP\.|CAPSULE|SYRUP|SYP|INJ|INJECTION)\b', cleaned):
        return True

    return False


def clean_name(text: str):

    # Remove OCR junk before extracting the name
    text = re.sub(r'^[^A-Z]+', '', text)

    for prefix in MEDICINE_PREFIXES:
        if text.upper().startswith(prefix):
            return text[len(prefix):].strip()

    return text.strip()


def is_food_instruction(text: str):

    text = text.upper()

    return any(
        item in text
        for item in FOOD_INSTRUCTIONS
    )


def is_ignored_line(text: str):

    text = text.upper()

    return any(
        item == text
        for item in IGNORE_LINES
    )
