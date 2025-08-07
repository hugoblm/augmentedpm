from fastapi import APIRouter

router = APIRouter()

@router.get("")
async def list_webinars():
    return [{"id": "1", "title": "Product Analytics avec IA"}]

