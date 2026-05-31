import sys
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Ensure `backend/` is on sys.path (Render: uvicorn main:app; CLI: backend.main).
sys.path.insert(0, str(Path(__file__).resolve().parent))

from router.auth import router as auth_router
from router.balance import router as balance_router
from router.insights import router as insights_router
from router.transactions import router as transactions_router
from router.wallet import router as wallet_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(balance_router)
app.include_router(insights_router)
app.include_router(transactions_router)
app.include_router(wallet_router)


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on my Mac!"}
