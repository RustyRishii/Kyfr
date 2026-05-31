from fastapi import FastAPI

try:
    from .insights import router as insights_router
except ImportError:
    from insights import router as insights_router

app = FastAPI()

app.include_router(insights_router)


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on my Mac!"}
