from __future__ import annotations

import re
import secrets
from dataclasses import dataclass, field
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import Header, HTTPException, status


EMAIL_PATTERN = re.compile(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")


@dataclass
class Transaction:
    id: str
    user_id: str
    title: str
    subtitle: str
    amount: float
    kind: str
    status: str = "success"
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_dict(self) -> dict[str, object]:
        return {
            "id": self.id,
            "title": self.title,
            "subtitle": self.subtitle,
            "amount": self.amount,
            "kind": self.kind,
            "status": self.status,
            "created_at": self.created_at.isoformat(),
        }


@dataclass
class User:
    id: str
    name: str
    email: str
    password: str
    balance: float = 0

    def to_public_dict(self) -> dict[str, str]:
        return {"id": self.id, "name": self.name, "email": self.email}


users_by_email: dict[str, User] = {}
tokens: dict[str, str] = {}
transactions_by_user: dict[str, list[Transaction]] = {}


def normalize_email(email: str) -> str:
    return email.strip().lower()


def validate_email(email: str) -> str:
    normalized = normalize_email(email)
    if not EMAIL_PATTERN.match(normalized):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Enter a valid email address.",
        )
    return normalized


def create_token(user_id: str) -> str:
    token = secrets.token_urlsafe(32)
    tokens[token] = user_id
    return token


def add_transaction(
    *,
    user_id: str,
    title: str,
    subtitle: str,
    amount: float,
    kind: str,
) -> Transaction:
    transaction = Transaction(
        id=f"txn-{uuid4().hex[:12]}",
        user_id=user_id,
        title=title,
        subtitle=subtitle,
        amount=round(amount, 2),
        kind=kind,
    )
    transactions_by_user.setdefault(user_id, []).insert(0, transaction)
    return transaction


def create_user(*, name: str, email: str, password: str, balance: float = 0) -> User:
    normalized = validate_email(email)
    if normalized in users_by_email:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        )

    user = User(
        id=f"user-{uuid4().hex[:10]}",
        name=name.strip(),
        email=normalized,
        password=password,
        balance=round(balance, 2),
    )
    users_by_email[normalized] = user
    transactions_by_user[user.id] = []
    return user


def get_or_create_mock_recipient(email: str) -> User:
    normalized = validate_email(email)
    existing = users_by_email.get(normalized)
    if existing is not None:
        return existing

    display_name = normalized.split("@", maxsplit=1)[0].replace(".", " ").title()
    return create_user(
        name=display_name or "Kyfr User",
        email=normalized,
        password=secrets.token_urlsafe(12),
    )


def authenticate(email: str, password: str) -> User:
    normalized = validate_email(email)
    user = users_by_email.get(normalized)
    if user is None or user.password != password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )
    return user


def get_user_by_token(token: str) -> User | None:
    user_id = tokens.get(token)
    if user_id is None:
        return None
    return next((user for user in users_by_email.values() if user.id == user_id), None)


def get_current_user(authorization: str | None = Header(default=None)) -> User:
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing auth token.",
        )

    token = authorization.removeprefix("Bearer ").strip()
    user = get_user_by_token(token)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid auth token.",
        )
    return user


def user_transactions(user_id: str) -> list[dict[str, object]]:
    return [transaction.to_dict() for transaction in transactions_by_user.get(user_id, [])]


def wallet_for(user: User) -> dict[str, object]:
    return {"balance": user.balance, "transactions": user_transactions(user.id)}


def seed_demo_data() -> None:
    if users_by_email:
        return

    demo = create_user(
        name="Rishi",
        email="demo@kyfr.com",
        password="password123",
        balance=12500,
    )
    create_token(demo.id)
    add_transaction(
        user_id=demo.id,
        title="Sent to Priya",
        subtitle="Transfer",
        amount=850,
        kind="debit",
    )
    add_transaction(
        user_id=demo.id,
        title="Added money",
        subtitle="Wallet top up",
        amount=5000,
        kind="credit",
    )
    add_transaction(
        user_id=demo.id,
        title="Sent to Aman",
        subtitle="Transfer",
        amount=1200,
        kind="debit",
    )
    create_user(name="Priya", email="priya@test.com", password="password123")
    create_user(name="Aman", email="aman@test.com", password="password123")


seed_demo_data()
