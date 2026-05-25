"""
Railway server — new endpoint for menu image analysis.
Add this route to your existing FastAPI app (alongside /analyze-food-image).

Required env vars (already used by the existing endpoint):
  GEMINI_API_KEY   — your Google Gemini API key

Dependencies (same as existing):
  pip install fastapi google-generativeai pillow python-multipart
"""

import os
import base64
import json
import re
import logging

import google.generativeai as genai
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

logger = logging.getLogger(__name__)

# ── Configure Gemini (once, at module level) ──────────────────────────────────
genai.configure(api_key=os.environ["GEMINI_API_KEY"])
_MODEL = genai.GenerativeModel("gemini-1.5-flash")  # or gemini-pro-vision

# ── Request / Response schemas ────────────────────────────────────────────────

class MenuAnalysisRequest(BaseModel):
    imageBase64: str
    mimeType: str = "image/jpeg"
    mode: str = "menu"           # client sends "menu" as a hint
    systemPrompt: str | None = None  # optional override from client

class MenuAnalysisResponse(BaseModel):
    dishes: list[dict]
    rawMenuText: str | None = None

# ── Router ────────────────────────────────────────────────────────────────────

router = APIRouter()

_DEFAULT_PROMPT = """
You are a professional nutritionist and OCR expert analyzing a café or restaurant menu photo.

YOUR TASK:
1. Read ALL visible text from the image using OCR — names, descriptions, weights, prices.
2. Identify each individual dish or item listed in the menu.
3. For every dish, estimate its likely ingredients based on the dish name and any description.
4. Calculate approximate nutritional values (КБЖУ): calories (kcal), protein (g), fat (g), carbohydrates (g).
5. Assign a confidence score (0.0–1.0) reflecting how certain you are about the nutritional data.

STRICT RULES:
- Do NOT invent dishes that are not visible in the image.
- If the image is blurry or a section is illegible, skip that dish — do not guess its name.
- If confidence < 0.6, set isApproximate = true.
- Never claim exact precision for КБЖУ; values are always estimates.
- Return ONLY valid JSON — no markdown, no extra text, no explanation.

OUTPUT FORMAT (strict JSON, no markdown fences):
{
  "dishes": [
    {
      "dishName": "Caesar Salad",
      "description": "Romaine lettuce, croutons, parmesan, caesar dressing",
      "weight": "250g",
      "price": 1200,
      "estimatedIngredients": ["romaine lettuce", "chicken breast", "croutons", "parmesan", "caesar dressing"],
      "calories": 380,
      "protein": 28.5,
      "fats": 22.0,
      "carbs": 18.5,
      "confidence": 0.85,
      "isApproximate": false
    }
  ],
  "rawMenuText": "full OCR text of the menu here"
}
"""


def _strip_fences(text: str) -> str:
    """Remove markdown code fences that the model sometimes wraps JSON in."""
    text = text.strip()
    match = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text)
    if match:
        return match.group(1).strip()
    return text


@router.post("/analyze-menu-image", response_model=MenuAnalysisResponse)
async def analyze_menu_image(req: MenuAnalysisRequest):
    """
    Accepts a base64-encoded menu photo and returns structured КБЖУ data
    for every dish found in the menu.
    """
    try:
        # Decode image
        image_bytes = base64.b64decode(req.imageBase64)
        image_part = {"mime_type": req.mimeType, "data": image_bytes}

        # Choose prompt (client can override)
        prompt = req.systemPrompt or _DEFAULT_PROMPT

        logger.info("Sending menu image to Gemini (%d bytes)", len(image_bytes))
        response = _MODEL.generate_content([prompt, image_part])

        raw_text = response.text.strip()
        logger.debug("Gemini raw response: %s", raw_text[:500])

        # Parse JSON
        json_text = _strip_fences(raw_text)
        data = json.loads(json_text)

        dishes = data.get("dishes", [])
        raw_menu_text = data.get("rawMenuText")

        if not dishes:
            raise HTTPException(
                status_code=422,
                detail="No dishes were detected. Try a clearer photo of the menu.",
            )

        return MenuAnalysisResponse(dishes=dishes, rawMenuText=raw_menu_text)

    except json.JSONDecodeError as e:
        logger.error("JSON parse error: %s | raw: %s", e, raw_text[:300])
        raise HTTPException(
            status_code=500,
            detail=f"AI returned invalid JSON: {str(e)}",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Unexpected error in /analyze-menu-image")
        raise HTTPException(status_code=500, detail=str(e))


# ── How to register this router in your main app ──────────────────────────────
# In your main.py / app.py:
#
#   from menu_analysis_router import router as menu_router
#   app.include_router(menu_router)
