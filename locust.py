# locustfile.py
from locust import HttpUser, task, between

class QuizAppUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self):
        # visit login page
        self.client.get("/login")

        # login as normal user
        self.client.post(
            "/login",
            data={
                "username": "admin",
                "password": "admin123",
                "role": "admin"
            },
            allow_redirects=True
        )

    @task(3)
    def user_dashboard(self):
        self.client.get("/user_dashboard")

    @task(2)
    def view_quizzes(self):
        self.client.get("/view_quizzes")

    @task(1)
    def admin_dashboard(self):
        self.client.get("/admin/dashboard")

    @task(1)
    def logout(self):
        self.client.get("/logout")
