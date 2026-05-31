from datetime import datetime, timezone
from uuid import uuid4

from fastapi import Header, HTTPException, status


users = {
    "user-1": {
        "id": "user-1",
        "name": "Demo User",
        "email": "demo@kyfr.com",
        "password": "password123",
        "balance": 12500.0,
    }
}

tokens = {"demo-token": "user-1"}

transactions = {
    "user-1": [
        {
            "id": "txn-003",
            "title": "Sent to Priya",
            "subtitle": "Transfer",
            "amount": 850.0,
            "type": "DEBIT",
            "status": "SUCCESS",
            "created_at": "2026-05-31T08:30:00Z",
        },
        {
            "id": "txn-002",
            "title": "Added money",
            "subtitle": "Wallet top up",
            "amount": 5000.0,
            "type": "CREDIT",
            "status": "SUCCESS",
            "created_at": "2026-05-30T10:00:00Z",
        },
        {
            "id": "txn-001",
            "title": "Sent to Aman",
            "subtitle": "Transfer",
            "amount": 1200.0,
            "type": "DEBIT",
            "status": "SUCCESS",
            "created_at": "2026-05-29T12:00:00Z",
        },
    ]
}


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def public_user(user: dict) -> dict:
    return {"id": user["id"], "name": user["name"], "email": user["email"]}


def find_user_by_email(email: str) -> dict | None:
    normalized_email = email.strip().lower()
    return next(
        (user for user in users.values() if user["email"] == normalized_email),
        None,
    )


def create_user(name: str, email: str, password: str) -> dict:
    normalized_email = email.strip().lower()
    if find_user_by_email(normalized_email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="User already exists",
        )

    user_id = f"user-{len(users) + 1}"
    user = {
        "id": user_id,
        "name": name.strip(),
        "email": normalized_email,
        "password": password,
        "balance": 0.0,
    }
    users[user_id] = user
    transactions[user_id] = []
    return user


def create_token(user_id: str) -> str:
    token = f"mock-token-{uuid4().hex}"
    tokens[token] = user_id
    return token


def get_current_user(authorization: str | None = Header(default=None)) -> dict:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
        )

    token = authorization.removeprefix("Bearer ").strip()
    user_id = tokens.get(token)
    if not user_id or user_id not in users:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    return users[user_id]


def add_transaction(
    user_id: str,
    title: str,
    subtitle: str,
    amount: float,
    transaction_type: str,
) -> dict:
    transaction = {
        "id": f"txn-{uuid4().hex[:10]}",
        "title": title,
        "subtitle": subtitle,
        "amount": amount,
        "type": transaction_type,
        "status": "SUCCESS",
        "created_at": _now_iso(),
    }
    transactions.setdefault(user_id, []).insert(0, transaction)
    return transaction
