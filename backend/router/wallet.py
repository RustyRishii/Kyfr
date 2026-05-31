from fastapi import APIRouter, Depends, HTTPException, status

from schemas import AddMoneyRequest, TransferRequest
from store import add_transaction, find_user_by_email, get_current_user

router = APIRouter(prefix="/wallet", tags=["wallet"])


@router.get("/balance")
def get_balance(current_user: dict = Depends(get_current_user)):
    return {"balance": current_user["balance"]}


@router.post("/add-money")
def add_money(
    payload: AddMoneyRequest,
    current_user: dict = Depends(get_current_user),
):
    current_user["balance"] += payload.amount
    transaction = add_transaction(
        current_user["id"],
        title="Added money",
        subtitle="Wallet top up",
        amount=payload.amount,
        transaction_type="CREDIT",
    )
    return {"balance": current_user["balance"], "transaction": transaction}


@router.post("/transfer")
def transfer_money(
    payload: TransferRequest,
    current_user: dict = Depends(get_current_user),
):
    recipient = find_user_by_email(payload.recipient_email)
    if recipient and recipient["id"] == current_user["id"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot send money to yourself",
        )

    if payload.amount > current_user["balance"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient wallet balance",
        )

    current_user["balance"] -= payload.amount
    transaction = add_transaction(
        current_user["id"],
        title=f"Sent to {payload.recipient_email}",
        subtitle=payload.note.strip() or "Transfer",
        amount=payload.amount,
        transaction_type="DEBIT",
    )

    if recipient:
        recipient["balance"] += payload.amount
        add_transaction(
            recipient["id"],
            title=f"Received from {current_user['email']}",
            subtitle=payload.note.strip() or "Transfer",
            amount=payload.amount,
            transaction_type="CREDIT",
        )

    return {"balance": current_user["balance"], "transaction": transaction}

