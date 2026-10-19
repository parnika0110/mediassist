from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str
    APP_VERSION: str

    HOST: str
    PORT: int

    MAX_FILE_SIZE: int

    TEMP_FOLDER: str

    class Config:
        env_file = ".env"


@lru_cache
def get_settings():
    return Settings()