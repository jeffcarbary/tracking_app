docker exec -it budget-api /bin/sh
export FLASK_APP=migrate.py
export FLASK_ENV=development
flask db migrate -m "Add nutrition tables"
flask db upgrade
