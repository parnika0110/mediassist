import os
import pprint
import cv2

from app.ocr.preprocess import preprocess
from app.ocr.preprocess import save_processed_image
from app.ocr.paddle_engine import PrescriptionOCR


# ======================================================
# CHANGE THIS PATH TO YOUR IMAGE
# ======================================================

IMAGE_PATH = "C:/Users/DHANUSH REDDY/OneDrive/Desktop/maj proj/projects/mediassist-ocr/images/sample.jpg"


# ======================================================

print("=" * 60)
print("MediAssist OCR Test")
print("=" * 60)

print("\nCurrent Working Directory:")
print(os.getcwd())

print("\nChecking image...")

if not os.path.exists(IMAGE_PATH):
    raise FileNotFoundError(
        f"\nImage not found!\n\n{IMAGE_PATH}"
    )

print("Image Found")

# ------------------------------------------------------
# PREPROCESSING
# ------------------------------------------------------

print("\nRunning preprocessing...")

processed = preprocess(IMAGE_PATH)

save_processed_image(
    processed,
    "processed.jpg"
)

print("Processed image saved as processed.jpg")

# ------------------------------------------------------
# OCR
# ------------------------------------------------------

print("\nLoading OCR Engine...")

ocr = PrescriptionOCR()

print("OCR Loaded Successfully")

print("\nRunning OCR...")

raw_result = ocr.extract_text(IMAGE_PATH)

print("\n")
print("=" * 60)
print("RAW OCR OUTPUT")
print("=" * 60)

pprint.pp(raw_result)

print("\n")
print("=" * 60)
print("FILTERED OCR TEXT")
print("=" * 60)

text = ocr.run(IMAGE_PATH)

print(text)

print("\n")
print("=" * 60)
print("TEST COMPLETED")
print("=" * 60)