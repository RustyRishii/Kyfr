from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI on my Mac!"}


@app.get("/insights")
def get_insights():
    return {"message": "You spent most of your money on transfers this weekj"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "query": q}
