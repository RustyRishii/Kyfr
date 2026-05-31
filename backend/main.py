from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

try:
    from .auth import router as auth_router
    from .insights import router as insights_router
    from .realtime import router as realtime_router
    from .transactions import router as transactions_router
    from .wallet import router as wallet_router
except ImportError:
    from auth import router as auth_router
    from insights import router as insights_router
    from realtime import router as realtime_router
    from transactions import router as transactions_router
    from wallet import router as wallet_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(insights_router)
app.include_router(wallet_router)
app.include_router(transactions_router)
app.include_router(realtime_router)


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on my Mac!"}
