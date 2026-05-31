from fastapi import APIRouter, HTTPException, status

from schemas import AuthResponse, LoginRequest, SignupRequest
from store import create_token, create_user, find_user_by_email, public_user

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=AuthResponse)
def signup(payload: SignupRequest):
    user = create_user(payload.name, payload.email, payload.password)
    token = create_token(user["id"])
    return {"token": token, "user": public_user(user)}


@router.post("/login", response_model=AuthResponse)
def login(payload: LoginRequest):
    user = find_user_by_email(payload.email)
    if not user or user["password"] != payload.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    token = create_token(user["id"])
    return {"token": token, "user": public_user(user)}

