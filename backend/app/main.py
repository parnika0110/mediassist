"""
main.py

Main entry point for the MediAssist OCR Backend.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.prescription import router as prescription_router


# ---------------------------------------------------------
# Application Lifespan
# ---------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("\n===================================")
    print(" MediAssist OCR Backend Started")
    print("===================================\n")

    yield

    print("\n===================================")
    print(" MediAssist OCR Backend Shutdown")
    print("===================================\n")


# ---------------------------------------------------------
# FastAPI App
# ---------------------------------------------------------

app = FastAPI(
    title="MediAssist OCR API",
    description="AI-powered Prescription OCR and Medicine Extraction API",
    version="1.0.0",
    lifespan=lifespan,
)

# ---------------------------------------------------------
# CORS
# ---------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Restrict this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# Routers
# ---------------------------------------------------------

app.include_router(prescription_router)

# ---------------------------------------------------------
# Root Endpoint
# ---------------------------------------------------------

@app.get("/")
async def root():
    return {
        "application": "MediAssist OCR API",
        "version": "1.0.0",
        "status": "Running",
        "documentation": "/docs",
    }

# ---------------------------------------------------------
# Health Check
# ---------------------------------------------------------

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "service": "MediAssist OCR Backend",
    }