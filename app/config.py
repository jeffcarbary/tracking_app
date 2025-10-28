import os
from dotenv import load_dotenv

# Load environment variables from the secrets folder
load_dotenv(dotenv_path="./secrets/.env")

class Config:
    FLASK_PORT = int(os.getenv("FLASK_PORT", 5000))
    FLASK_HOST = os.getenv("FLASK_HOST", "127.0.0.1")
    SQLALCHEMY_DATABASE_URI = (
        f"postgresql://{os.getenv('DATABASE_USER')}:{os.getenv('DATABASE_PASSWORD')}"
        f"@{os.getenv('DATABASE_HOST')}:{os.getenv('DATABASE_PORT')}/{os.getenv('DATABASE_NAME')}"
    )
#    SQLALCHEMY_DATABASE_URI = "postgresql://SECRET:SECRET@localhost/budget_db"
    SQLALCHEMY_TRACK_MODIFICATIONS = False

print(Config.SQLALCHEMY_DATABASE_URI)
