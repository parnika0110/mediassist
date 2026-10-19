from pydantic import BaseModel


class Medicine(BaseModel):
    medicine: str
    dosage: str
    frequency: str
    duration: str


class OCRResponse(BaseModel):
    success: bool
    medicines: list[Medicine]