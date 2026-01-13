import os
class Config:
    SECRET_KEY = 'supersecretkey'
    # Use the Kubernetes service name for MySQL
    SQLALCHEMY_DATABASE_URI = 'mysql://quiz-user:password@mysql-service:3306/quizdb'
    SQLALCHEMY_TRACK_MODIFICATIONS = False



