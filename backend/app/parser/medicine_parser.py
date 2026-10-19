import re
from typing import List

from app.parser.frequency_parser import parse_frequency
from app.parser.medicine_model import Medicine
from app.parser.validators import (
    clean_name,
    is_food_instruction,
    is_ignored_line,
    is_medicine_line,
)


class MedicineParser:

    def __init__(self):

        self.duration_pattern = re.compile(
            r"\d+\s*(DAY|DAYS|WEEK|WEEKS|MONTH|MONTHS)",
            re.IGNORECASE,
        )

    # -------------------------------------------------------
    # Duration detection
    # -------------------------------------------------------

    def is_duration(self, text):

        return bool(self.duration_pattern.search(text))

    # -------------------------------------------------------
    # Helpers
    # -------------------------------------------------------

    def extract_dosage(self, text):

        """
        Supports:

        500 MG
        650
        """

        if not text:
            return 0, "mg"

        match = re.search(
            r"(\d+)\s*(MG|MCG|ML|GM|G)",
            text,
            re.IGNORECASE,
        )

        if match:

            return (
                int(match.group(1)),
                match.group(2).lower(),
            )

        match = re.search(r"\b(\d{2,4})\b", text)

        if match:

            return (
                int(match.group(1)),
                "mg",
            )

        return 0, "mg"

    def extract_duration(self, text):

        if not text:

            return 0, "Day"

        match = re.search(
            r"(\d+)\s*(DAY|DAYS|WEEK|WEEKS|MONTH|MONTHS)",
            text,
            re.IGNORECASE,
        )

        if not match:

            return 0, "Day"

        value = int(match.group(1))

        unit = match.group(2).capitalize()

        if unit.endswith("s"):
            unit = unit[:-1]

        return value, unit

    def extract_frequency(self, frequency):

        """
        1-0-1
        """

        if not frequency:

            return 0, 0, 0

        match = re.match(
            r"(\d+)-(\d+)-(\d+)",
            frequency,
        )

        if not match:

            return 0, 0, 0

        return (
            int(match.group(1)),
            int(match.group(2)),
            int(match.group(3)),
        )

    # -------------------------------------------------------
    # GROUP OCR INTO MEDICINE BLOCKS
    # -------------------------------------------------------

    def build_blocks(self, lines: List[str]):

        blocks = []

        current = []

        for line in lines:

            line = line.strip()

            if not line:
                continue

            if is_ignored_line(line):
                continue

            if is_medicine_line(line):

                if current:
                    blocks.append(current)

                current = [line]

            elif current:

                current.append(line)

        if current:
            blocks.append(current)

        return blocks

    # -------------------------------------------------------
    # PARSE SINGLE BLOCK
    # -------------------------------------------------------

    def parse_block(self, block):

        medicine_name = clean_name(block[0])

        dosage = 0
        dosage_unit = "mg"

        morning = 0
        afternoon = 0
        night = 0

        duration = 0
        duration_unit = "Day"

        instructions = ""

        # dosage may exist inside medicine name

        dosage, dosage_unit = self.extract_dosage(
            medicine_name
        )

        # remove dosage from medicine name

        medicine_name = re.sub(
            r"\d+\s*(MG|MCG|ML|GM|G)?",
            "",
            medicine_name,
            flags=re.IGNORECASE,
        ).strip()

        for line in block[1:]:

            freq = parse_frequency(line)

            if freq:

                (
                    morning,
                    afternoon,
                    night,
                ) = self.extract_frequency(freq)

                continue

            if self.is_duration(line):

                (
                    duration,
                    duration_unit,
                ) = self.extract_duration(line)

                continue

            if any(
                unit in line.upper()
                for unit in ["MG", "MCG", "ML", "GM", "G"]
            ):

                dosage, dosage_unit = self.extract_dosage(
                    line
                )

                continue

            if is_food_instruction(line):

                if instructions:
                    instructions += " "

                instructions += line

                continue

            if instructions:
                instructions += " "

            instructions += line

        return Medicine(
            medicine=medicine_name,
            dosage=dosage,
            dosage_unit=dosage_unit,
            morning=morning,
            afternoon=afternoon,
            night=night,
            duration=duration,
            duration_unit=duration_unit,
            instructions=instructions,
        )

    # -------------------------------------------------------
    # MAIN PARSER
    # -------------------------------------------------------

    def parse(self, lines):

        print("\n========= LINES RECEIVED =========")
        for i, line in enumerate(lines):
            print(f"{i+1}: {line}")
    
        medicines = []
    
        blocks = self.build_blocks(lines)
    
        print("\n========= BLOCKS =========")
        for i, block in enumerate(blocks):
            print(f"BLOCK {i+1}")
            for l in block:
                print("   ", l)
    
        for block in blocks:
            medicines.append(self.parse_block(block))
    
        return medicines

    # -------------------------------------------------------
    # API RESPONSE
    # -------------------------------------------------------

    def to_json(self, medicines):

        return {
            "medicines": [
                {
                    "medicineName": m.medicine,
                    "dosage": m.dosage,
                    "dosageUnit": m.dosage_unit,
                    "morning": m.morning,
                    "afternoon": m.afternoon,
                    "night": m.night,
                    "duration": m.duration,
                    "durationUnit": m.duration_unit,
                    "instructions": m.instructions,
                }
                for m in medicines
            ]
        }
