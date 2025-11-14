#!/bin/sh
set -e
export FLASK_APP=run:create_app
export FLASK_ENV=development
export FLASK_RUN_HOST=0.0.0.0

echo "Waiting for Postgres..."

until python - <<END
import psycopg2, os
try:
    conn = psycopg2.connect(
        host=os.environ['DATABASE_HOST'],
        port=os.environ['DATABASE_PORT'],
        user=os.environ['DATABASE_USER'],
        password=os.environ['DATABASE_PASSWORD'],
        dbname=os.environ['DATABASE_NAME']
    )
    conn.close()
except psycopg2.OperationalError:
    exit(1)
END
do
  sleep 1
done

echo "Postgres ready."
flask db upgrade

#flask run
flask run --host=0.0.0.0 --reload
