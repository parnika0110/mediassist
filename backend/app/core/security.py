import uuid
from pathlib import Path

from fastapi import HTTPException, UploadFile


ALLOWED_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg"
}

ALLOWED_MIME = {
    "image/png",
    "image/jpeg"
}


def validate_image(file: UploadFile, max_size: int):

    if file.content_type not in ALLOWED_MIME:
        raise HTTPException(
            status_code=400,
            detail="Unsupported image type"
        )

    extension = Path(file.filename).suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Invalid file extension"
        )


def generate_filename(extension: str):

    return f"{uuid.uuid4().hex}{extension}"