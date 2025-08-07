from fastapi import APIRouter

router = APIRouter()

@router.get("")
async def list_formations():
    return [
        {"id": "pm-ai-fundamentals", "title": "Fundamentaux PM IA", "level": "beginner"}
    ]

@router.get("/{formation_id}")
async def get_formation(formation_id: str):
    return {"id": formation_id, "title": "Formation", "modules": []}

