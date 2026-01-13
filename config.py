import os
class Config:
    SECRET_KEY = 'supersecretkey'
    # Use the Kubernetes service name for MySQL
    SQLALCHEMY_DATABASE_URI = 'mysql+mysqldb://quiz_user:paasword@mysql-service:3306/quizdb'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

