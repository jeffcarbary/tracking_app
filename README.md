# Budget and Nutritional Logging App

A flask-based web API for tracking budget transactions - extended as a nutrition logger/tracker, backed by PostgreSQL and deployed in kubernetes cluster with active replication to backup persistent volume.
Code is 90% AI Generated integrated and built manually.


## Features
- REST API with Flask
- PostgreSQL database
- SQLAlchemy ORM + Flask-Migrate
- Kubernetes cluster deployment / statefulset
- Supports categories, transactions, and reporting
- Stores unique colors for each transaction category for reporting via front end and/or google sheet
- Add transaction page supports copy / paste from text message alert
- Integrates with google sheets for presentation and data backup / recovery
- Email report
- Tracking nutrional data including fiber, protein, and calories
- Easy to use interface for adding nutrition including searchable previous entries and auto calculating values
- Multi-user support
- Daily charts including projections and targets as well as overlaying yesterdays line on the chart for comparison
- Reports for month and week
- Metrics endpoint exposed for Prometheus / Grafana
  

