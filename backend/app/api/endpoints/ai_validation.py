from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class ValidateRequest(BaseModel):
    user_response: str
    case_id: str

@router.post("/validate")
async def validate_case(req: ValidateRequest):
    # Stub: renvoie un feedback déterministe
    return {
        "score": 78,
        "strengths": ["Structure claire", "Hypothèses explicites"],
        "improvements": ["Plus de données", "Clarifier les risques"],
        "training": ["pm-ai-fundamentals"]
    }

