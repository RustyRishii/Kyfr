from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

try:
    from .insights import router as insights_router
except ImportError:
    from insights import router as insights_router

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(insights_router)


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on my Mac!"}
