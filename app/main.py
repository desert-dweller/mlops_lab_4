# app/main.py
from fastapi import FastAPI

app = FastAPI(title="MLOps Course - Hello World API")

@app.get("/", tags=["Greeting"])
def read_root():
    """Returns a simple greeting message."""
    return {"message": "Hello from your deployed app on Render!"}