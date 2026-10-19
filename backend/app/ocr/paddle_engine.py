"""
paddle_engine.py

PaddleOCR engine for MediAssist.

Responsibilities:
- Preprocess image
- Run PaddleOCR
- Filter low-confidence text
- Return extracted text
"""

from typing import List

import cv2
from loguru import logger
from paddleocr import PaddleOCR

from app.ocr.preprocess import preprocess


# -------------------------------------------------------
# Initialize OCR once (Singleton)
# -------------------------------------------------------

ocr_engine = PaddleOCR(
    lang="en",

    use_doc_orientation_classify=False,
    use_doc_unwarping=False,
    use_textline_orientation=False,

    text_detection_model_name="PP-OCRv5_mobile_det",
    text_recognition_model_name="en_PP-OCRv5_mobile_rec",
)


class PrescriptionOCR:
    """
    OCR Engine for prescription images.
    """

    def __init__(self):
        self.ocr = ocr_engine

    def extract_text(self, image_path: str):
        """
        Run PaddleOCR on a preprocessed image.
        Returns the raw PaddleOCR output.
        """

        try:
            processed = preprocess(image_path)

            # PaddleOCR expects a 3-channel image
            if len(processed.shape) == 2:
                processed = cv2.cvtColor(
                    processed,
                    cv2.COLOR_GRAY2BGR
                )

            result = self.ocr.predict(processed)

            return result

        except Exception as e:
            logger.exception(f"OCR failed: {e}")
            raise

    def clean_text(self, text: str) -> str:
        """
        Basic cleanup only.
        Preserve numbers because they are important
        for dosage and frequency.
        """

        return " ".join(text.strip().split())

    def filter_text(
        self,
        result,
        threshold: float = 0.80
    ) -> List[str]:
        """
        Extract high-confidence text lines from
        PaddleOCR output.
        """

        filtered = []

        if not result:
            return filtered

        for page in result:

            texts = page.get("rec_texts", [])
            scores = page.get("rec_scores", [])

            for text, score in zip(texts, scores):

                if score >= threshold:

                    cleaned = self.clean_text(text)

                    if cleaned:
                        filtered.append(cleaned)

        return filtered

    def combine_text(self, lines: List[str]) -> str:
        """
        Convert OCR lines into one multiline string.
        """

        return "\n".join(lines)

    def run(self, image_path: str) -> str:
        """
        Complete OCR pipeline.
        """

        logger.info("Starting OCR")

        raw_result = self.extract_text(image_path)

        filtered = self.filter_text(raw_result)

        text = self.combine_text(filtered)

        logger.info("OCR Finished")

        return text

    def get_lines(self, image_path: str) -> List[str]:
        """
        Return OCR as a list of cleaned text lines.
        Useful for the medicine parser.
        """

        raw_result = self.extract_text(image_path)

        return self.filter_text(raw_result)


# -------------------------------------------------------
# Singleton instance
# -------------------------------------------------------

ocr = PrescriptionOCR()
