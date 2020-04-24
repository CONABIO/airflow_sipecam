#!/bin/bash

superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin && \
sleep 10 && \
superset db upgrade && \
superset init
