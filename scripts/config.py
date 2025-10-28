import os
from dotenv import load_dotenv

# Load .env file
load_dotenv(dotenv_path="./secrets/.env")

# Read values from environment
API_BASE_URL = os.environ.get("API_BASE_URL")
