from __future__ import print_function

from airflow import models, settings
from airflow.contrib.auth.backends.password_auth import PasswordUser
import sys


session = settings.Session()
exists = session.query(
    models.User).filter(
        models.User.username == <your_user_name>).scalar()

if exists:
    print("**********************************************", file=sys.stderr)
    print("**********************************************", file=sys.stderr)
    print('User already exists!', file=sys.stderr)
    print("**********************************************")
    print("**********************************************")
    print('User already exists!')
else:
    user = PasswordUser(models.User())
    user.username = <your_user_name>
    user.email = <your_email>
    user.password = <your_password>
    user.superuser = True
    session.add(user)
    session.commit()
    session.close()
    print("**********************************************", file=sys.stderr)
    print("**********************************************", file=sys.stderr)
    print('just added user!', file=sys.stderr)
    print("**********************************************")
    print("**********************************************")
    print('just added user!')
