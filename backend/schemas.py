from pydantic import BaseModel, Field


class SignupRequest(BaseModel):
    name: str = Field(min_length=1)
    email: str = Field(min_length=3)
    password: str = Field(min_length=6)


class LoginRequest(BaseModel):
    email: str = Field(min_length=3)
    password: str = Field(min_length=6)


class AddMoneyRequest(BaseModel):
    amount: float = Field(gt=0)


class TransferRequest(BaseModel):
    recipient_email: str = Field(min_length=3)
    amount: float = Field(gt=0)
    note: str = ""


class UserResponse(BaseModel):
    id: str
    name: str
    email: str


class AuthResponse(BaseModel):
    token: str
    user: UserResponse

