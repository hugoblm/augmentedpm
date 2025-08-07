from fastapi import APIRouter
from .endpoints import auth, formations, users, ai_validation, webinaires

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(formations.router, prefix="/formations", tags=["formations"])
api_router.include_router(webinaires.router, prefix="/webinaires", tags=["webinaires"])
api_router.include_router(ai_validation.router, prefix="/ai", tags=["ai"]) 

