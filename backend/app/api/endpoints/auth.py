from fastapi import APIRouter

router = APIRouter()

@router.post("/login")
async def login():
    return {"token": "dev-token"}

@router.post("/register")
async def register():
    return {"status": "registered"}

