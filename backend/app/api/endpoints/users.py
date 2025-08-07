from fastapi import APIRouter

router = APIRouter()

@router.get("/{user_id}")
async def get_user(user_id: str):
    return {"id": user_id, "email": "user@example.com"}

