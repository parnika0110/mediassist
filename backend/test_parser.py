from pprint import pprint

from app.ocr.paddle_engine import PrescriptionOCR
from app.parser.medicine_parser import MedicineParser

IMAGE_PATH = r"C:\Users\DHANUSH REDDY\OneDrive\Desktop\maj proj\projects\mediassist-ocr\images\sample.jpg"


ocr = PrescriptionOCR()
parser = MedicineParser()

# Get OCR lines
lines = ocr.get_lines(IMAGE_PATH)

print("=" * 60)
print("OCR LINES")
print("=" * 60)

for line in lines:
    print(line)

print("\n")

# Parse medicines
medicines = parser.parse(lines)

print("=" * 60)
print("PARSED OBJECTS")
print("=" * 60)

pprint(parser.to_json(medicines))
print("=" * 60)
print("BLOCKS")
print("=" * 60)

blocks = parser.build_blocks(lines)

for i, block in enumerate(blocks, start=1):
    print(f"\nMedicine {i}")
    for item in block:
        print("  ", item)