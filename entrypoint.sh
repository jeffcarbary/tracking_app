#!/bin/sh
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
# start Flask app as a module
exec python -m app.budget_app
