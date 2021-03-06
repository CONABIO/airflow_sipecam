import os

CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': 'redis',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 1,
    'CACHE_REDIS_URL': 'redis://redis:6379/1'}
SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://superset:superset@sspostgres:5432/superset'
SQLALCHEMY_TRACK_MODIFICATIONS = True

ROW_LIMIT = 5000
WEBSERVER_THREADS = 8
SUPERSET_WEBSERVER_PORT = 8088
SUPERSET_WEBSERVER_TIMEOUT =60
SECRET_KEY = 'tpytqplnepphccslm'
WTF_CSRF_ENABLED = True
WTF_CSRF_EXEMPT_LIST = []
MAPBOX_API_KEY = <your_mapbox_key>
