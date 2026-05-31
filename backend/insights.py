from fastapi import FastAPI

app = FastAPI()


@app.get("/insights")
def insights():
    return {"message": "You spent most of your money on transfers this week"}
