from fastapi import APIRouter, Depends

from store import get_current_user, transactions

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.get("")
def get_transactions(current_user: dict = Depends(get_current_user)):
    return {"transactions": transactions.get(current_user["id"], [])}

