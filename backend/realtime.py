from __future__ import annotations

from fastapi import APIRouter, WebSocket
from starlette.websockets import WebSocketDisconnect

try:
    from . import store
except ImportError:
    import store


router = APIRouter()


class ConnectionManager:
    def __init__(self) -> None:
        self._connections: dict[str, set[WebSocket]] = {}

    async def connect(self, user_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections.setdefault(user_id, set()).add(websocket)

    def disconnect(self, user_id: str, websocket: WebSocket) -> None:
        user_connections = self._connections.get(user_id)
        if user_connections is None:
            return
        user_connections.discard(websocket)
        if not user_connections:
            self._connections.pop(user_id, None)

    async def send_transaction(
        self,
        *,
        user_id: str,
        amount: float,
        balance: float,
        transaction: dict[str, object],
    ) -> None:
        payload = {
            "type": "TRANSACTION",
            "amount": amount,
            "status": "SUCCESS",
            "balance": balance,
            "transaction": transaction,
        }
        disconnected: list[WebSocket] = []
        for websocket in self._connections.get(user_id, set()).copy():
            try:
                await websocket.send_json(payload)
            except RuntimeError:
                disconnected.append(websocket)

        for websocket in disconnected:
            self.disconnect(user_id, websocket)


manager = ConnectionManager()


@router.websocket("/ws")
async def wallet_updates(websocket: WebSocket, token: str) -> None:
    user = store.get_user_by_token(token)
    if user is None:
        await websocket.close(code=1008)
        return

    await manager.connect(user.id, websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(user.id, websocket)
