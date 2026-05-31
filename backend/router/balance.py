from fastapi import APIRouter

from store import users

router = APIRouter()


@router.get("/balance")
def balance():
    return {"balance": users["user-1"]["balance"]}
