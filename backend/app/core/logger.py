import os

from loguru import logger

os.makedirs("logs", exist_ok=True)

logger.remove()

logger.add(
    "logs/app.log",
    rotation="10 MB",
    retention="10 days",
    compression="zip",
    enqueue=True,
    level="INFO",
)

logger.add(
    lambda msg: print(msg, end=""),
    level="INFO",
)

app_logger = logger