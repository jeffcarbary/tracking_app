#!/bin/bash
for x in  `ps aux|grep budget_app.py| grep -v grep| awk '{print $2}'`
do kill -9 $x
done
