from dataclasses import dataclass


@dataclass
class Medicine:
    medicine: str

    dosage: int = 0
    dosage_unit: str = "mg"

    morning: int = 0
    afternoon: int = 0
    night: int = 0

    duration: int = 0
    duration_unit: str = "Day"

    instructions: str = ""