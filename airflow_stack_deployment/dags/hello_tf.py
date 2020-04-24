from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator

from time import sleep
from datetime import datetime
import tensorflow as tf

def print_hello():
    sleep(5)
    txt = 'Num GPUs Available: {}'.format(len(tf.config.experimental.list_physical_devices('GPU')))
    return txt

with DAG('hello_tf_dag', description='First DAG with tf', schedule_interval='*/10 * * * *', start_date=datetime(2018, 11, 1), catchup=False) as dag:
    dummy_task     = DummyOperator(task_id='dummy_task', retries=3)
    python_task    = PythonOperator(task_id='python_task', python_callable=print_hello)

    dummy_task >> python_task
