"""Local runner. Set env vars before executing:

    SESAME_API_KEY=xxx ELASTICSEARCH_HOST=<EIP> python src/main.py
"""
from presentation.lambda_function import handler

if __name__ == "__main__":
    handler({}, None)
