import os
import uuid

from fastapi import UploadFile

UPLOAD_FOLDER = "uploads"

os.makedirs(
    UPLOAD_FOLDER,
    exist_ok=True
)


async def save_upload_file(file: UploadFile):

    extension = file.filename.split(".")[-1]

    filename = f"{uuid.uuid4()}.{extension}"

    path = os.path.join(
        UPLOAD_FOLDER,
        filename
    )

    with open(path, "wb") as f:

        content = await file.read()

        f.write(content)

    return path