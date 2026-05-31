from fastapi import APIRouter

router = APIRouter()


@router.get("/insights")
def insights():
    return {"message": "You spent most of your money on transfers this week"}
