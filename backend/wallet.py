from fastapi import APIRouter, Depends, HTTPException, status

try:
    from . import store
    from .realtime import manager
    from .schemas import AddMoneyRequest, BalanceResponse, TransferRequest, WalletResponse
except ImportError:
    import store
    from realtime import manager
    from schemas import AddMoneyRequest, BalanceResponse, TransferRequest, WalletResponse


router = APIRouter(tags=["wallet"])


@router.get("/balance", response_model=BalanceResponse)
def balance(user: store.User = Depends(store.get_current_user)) -> dict[str, float]:
    return {"balance": user.balance}


@router.get("/wallet", response_model=WalletResponse)
def wallet(user: store.User = Depends(store.get_current_user)) -> dict[str, object]:
    return store.wallet_for(user)


@router.post("/wallet/add-money", response_model=WalletResponse)
async def add_money(
    payload: AddMoneyRequest,
    user: store.User = Depends(store.get_current_user),
) -> dict[str, object]:
    user.balance = round(user.balance + payload.amount, 2)
    transaction = store.add_transaction(
        user_id=user.id,
        title="Added money",
        subtitle="Wallet top up",
        amount=payload.amount,
        kind="credit",
    )
    await manager.send_transaction(
        user_id=user.id,
        amount=payload.amount,
        balance=user.balance,
        transaction=transaction.to_dict(),
    )
    return store.wallet_for(user)


@router.post("/wallet/transfer", response_model=WalletResponse)
async def transfer_money(
    payload: TransferRequest,
    user: store.User = Depends(store.get_current_user),
) -> dict[str, object]:
    recipient_email = store.validate_email(payload.recipient_email)
    if recipient_email == user.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot send money to your own account.",
        )
    if payload.amount > user.balance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient wallet balance.",
        )

    recipient = store.get_or_create_mock_recipient(recipient_email)
    user.balance = round(user.balance - payload.amount, 2)
    recipient.balance = round(recipient.balance + payload.amount, 2)
    subtitle = payload.note.strip() or "Transfer"
    transaction = store.add_transaction(
        user_id=user.id,
        title=f"Sent to {recipient.email}",
        subtitle=subtitle,
        amount=payload.amount,
        kind="debit",
    )
    recipient_transaction = store.add_transaction(
        user_id=recipient.id,
        title=f"Received from {user.email}",
        subtitle=subtitle,
        amount=payload.amount,
        kind="credit",
    )

    await manager.send_transaction(
        user_id=user.id,
        amount=payload.amount,
        balance=user.balance,
        transaction=transaction.to_dict(),
    )
    await manager.send_transaction(
        user_id=recipient.id,
        amount=payload.amount,
        balance=recipient.balance,
        transaction=recipient_transaction.to_dict(),
    )
    return store.wallet_for(user)
