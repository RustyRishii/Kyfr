from fastapi import APIRouter

try:
    from . import store
    from .schemas import AuthResponse, LoginRequest, SignupRequest
except ImportError:
    import store
    from schemas import AuthResponse, LoginRequest, SignupRequest


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=AuthResponse)
def signup(payload: SignupRequest) -> dict[str, object]:
    user = store.create_user(
        name=payload.name,
        email=payload.email,
        password=payload.password,
    )
    token = store.create_token(user.id)
    return {"token": token, "user": user.to_public_dict()}


@router.post("/login", response_model=AuthResponse)
def login(payload: LoginRequest) -> dict[str, object]:
    user = store.authenticate(payload.email, payload.password)
    token = store.create_token(user.id)
    return {"token": token, "user": user.to_public_dict()}
