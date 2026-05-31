from fastapi import APIRouter, Depends

try:
    from . import store
    from .schemas import TransactionResponse
except ImportError:
    import store
    from schemas import TransactionResponse


router = APIRouter(tags=["transactions"])


@router.get("/transactions", response_model=list[TransactionResponse])
def transactions(
    user: store.User = Depends(store.get_current_user),
) -> list[dict[str, object]]:
    return store.user_transactions(user.id)
