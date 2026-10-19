from fastapi import APIRouter, File, HTTPException, UploadFile

from app.ocr.paddle_engine import PrescriptionOCR
from app.parser.medicine_parser import MedicineParser
from app.utils.file_handler import save_upload_file

router = APIRouter(
    prefix="/prescription",
    tags=["Prescription OCR"]
)

ocr = PrescriptionOCR()
parser = MedicineParser()


@router.post("/extract")
async def extract_prescription(
    file: UploadFile = File(...)
):

    try:

        image_path = await save_upload_file(file)

        lines = ocr.get_lines(image_path)

        print("\n========== OCR OUTPUT ==========")
        for line in lines:
            print(line)
        print("================================\n")

        medicines = parser.parse(lines)

        print("\n========== PARSED MEDICINES ==========")
        print(medicines)
        print("======================================\n")

        return {
            "success": True,
            "medicine_count": len(medicines),
            "medicines": parser.to_json(medicines)
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )