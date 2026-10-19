from app.ocr.preprocess import preprocess
from app.ocr.preprocess import save_processed


def main():
    image = preprocess("images/sample.jpg") 

    save_processed(
        image,
        "processed.jpg"
    )

    print("✅ Image preprocessing completed.")
    print("Processed image saved as: processed.jpg")


if __name__ == "__main__":
    main()
