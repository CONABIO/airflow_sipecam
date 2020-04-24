#!/usr/bin/env bash
# dag_concurrency is 4 that means that my dag can run maximum r tasks at once
# parallelism is 4 that means that ther will be maximum 3 active tasks anywhere
# worker_concurrency is 1 that means that each worker can run maximum 1 task at once
set -ex
TRY_LOOP="20"

: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"
: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASSWORD:="airflow"}"
: "${POSTGRES_DB:="airflow"}"

# Defaults and back-compat
: "${AIRFLOW_HOME:="/usr/local/airflow"}"

cp /script/change_config.txt tmp
echo 'set /files/usr/local/airflow/airflow.cfg/core/fernet_key '${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")} >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/core/executor '${EXECUTOR:-Sequential}'Executor' >> tmp
augtool -sLAf tmp
rm tmp

# more config
cp /script/change_config.txt tmp
echo 'set /files/usr/local/airflow/airflow.cfg/scheduler/dag_dir_list_interval 1' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/scheduler/job_heartbeat_sec 1' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/scheduler/scheduler_heartbeat_sec 1' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/webserver/dag_default_view graph' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/scheduler/max_threads 1' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/core/parallelism 4' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/core/dag_concurrency 4' >> tmp
echo 'set /files/usr/local/airflow/airflow.cfg/celery/worker_concurrency 1' >> tmp
augtool -sLAf tmp
rm tmp

export AIRFLOW_HOME

if [ "${AUTH_ENABLE:=n}" == t ]; then
  cp /script/change_config.txt tmp
  echo "set /files/usr/local/airflow/airflow.cfg/webserver/authenticate True" >> tmp
  echo "set /files/usr/local/airflow/airflow.cfg/webserver/auth_backend airflow.contrib.auth.backends.password_auth" >> tmp
  augtool -sLAf tmp
  rm tmp
fi

# Load DAGs examples (default: Yes)
if [ "${LOAD_EX:=n}" == n ]
then
  cp /script/change_config.txt tmp
  echo "set /files/usr/local/airflow/airflow.cfg/core/load_examples False" >> tmp
  augtool -sLAf tmp
  rm tmp
fi

# Install custom python package if requirements.txt is present
if [ -e "/script/requirements.txt" ]; then
    $(command -v pip) install --user -r /script/requirements.txt
fi

if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_PREFIX=:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

if [ "$EXECUTOR" != "Sequential" ]; then
  cp /script/change_config.txt tmp
  echo 'set /files/usr/local/airflow/airflow.cfg/core/sql_alchemy_conn "postgresql+psycopg2://'$POSTGRES_USER':'$POSTGRES_PASSWORD'@'$POSTGRES_HOST':'$POSTGRES_PORT'/'$POSTGRES_DB'"' >> tmp
  echo 'set /files/usr/local/airflow/airflow.cfg/celery/result_backend "db+postgresql://'$POSTGRES_USER':'$POSTGRES_PASSWORD'@'$POSTGRES_HOST':'$POSTGRES_PORT'/'$POSTGRES_DB'"' >> tmp
  augtool -sLAf tmp
  rm tmp

  if [ "$1" != "flower" ]; then
    wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
  fi

fi

if [ "$EXECUTOR" = "Celery" ]; then
  cp /script/change_config.txt tmp
  echo 'set /files/usr/local/airflow/airflow.cfg/celery/broker_url "redis://'$REDIS_PREFIX$REDIS_HOST':'$REDIS_PORT'/1"' >> tmp
  augtool -sLAf tmp
  rm tmp

##  if [ "$1" != "scheduler" ]; then
##    wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
##  fi

fi

case "$1" in
  webserver)
    airflow initdb
    if [ "$EXECUTOR" = "Local" ] || [ "$EXECUTOR" = "Sequential" ]; then
      # With the "Local" and "Sequential" executors it should all run in one container.
      airflow scheduler &
    fi
    exec airflow webserver
    ;;
  worker|scheduler)
    # Give the webserver time to run initdb.
    sleep 10
    exec airflow "$@"
    ;;
  flower)
    sleep 10
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
