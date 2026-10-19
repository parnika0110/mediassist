"""
preprocess.py

Image preprocessing pipeline for MediAssist OCR.

Pipeline:
1. Load image
2. Resize (if required)
3. Convert to grayscale
4. Enhance contrast using CLAHE
5. Return processed image
"""

from pathlib import Path

import cv2
import numpy as np


class ImagePreprocessor:
    """
    Image preprocessing for OCR.
    """

    def __init__(self, max_width: int = 1200):
        self.max_width = max_width

    def load_image(self, image_path: str) -> np.ndarray:
        """
        Load image from disk.
        """

        path = Path(image_path)

        if not path.exists():
            raise FileNotFoundError(
                f"Image not found: {path.resolve()}"
            )

        image = cv2.imread(str(path))

        if image is None:
            raise ValueError(
                f"Unable to read image: {path.resolve()}"
            )

        return image

    def resize_image(self, image: np.ndarray) -> np.ndarray:
        """
        Resize only if image is wider than max_width.
        Keeps aspect ratio.
        """

        height, width = image.shape[:2]

        if width <= self.max_width:
            return image

        scale = self.max_width / width

        new_width = int(width * scale)
        new_height = int(height * scale)

        resized = cv2.resize(
            image,
            (new_width, new_height),
            interpolation=cv2.INTER_AREA
        )

        return resized

    def to_grayscale(self, image: np.ndarray) -> np.ndarray:
        """
        Convert image to grayscale.
        """

        return cv2.cvtColor(
            image,
            cv2.COLOR_BGR2GRAY
        )

    def enhance_contrast(self, image: np.ndarray) -> np.ndarray:
        """
        Improve local contrast using CLAHE.
        """

        clahe = cv2.createCLAHE(
            clipLimit=2.0,
            tileGridSize=(8, 8)
        )

        return clahe.apply(image)

    def preprocess(self, image_path: str) -> np.ndarray:
        """
        Complete preprocessing pipeline.
        """

        image = self.load_image(image_path)

        image = self.resize_image(image)

        image = self.to_grayscale(image)

        image = self.enhance_contrast(image)

        return image


# Singleton instance
_preprocessor = ImagePreprocessor()


def preprocess(image_path: str) -> np.ndarray:
    """
    Public function used by OCR engine.
    """

    return _preprocessor.preprocess(image_path)


def save_processed_image(
    image: np.ndarray,
    output_path: str
) -> None:
    """
    Save processed image for debugging.
    """

    output = Path(output_path)

    output.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    cv2.imwrite(
        str(output),
        image
    )