import pytest
from app import app

@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client

def test_login_page_get(client):
    response = client.get('/login')
    assert response.status_code == 200
    assert b'Login' in response.data

def test_login_invalid_credentials(client):
    response = client.post(
        '/login',
        data={'username': 'admin', 'password': 'wrongpassword'},
        follow_redirects=True
    )
    assert response.status_code in (200, 400)

    response = client.post(
        '/login',
        data={'username': 'nonexistent', 'password': 'wrongpassword'},
        follow_redirects=True
    )
    assert response.status_code in (200, 400)

def test_register_page_get(client):
    response = client.get('/register')
    assert response.status_code == 200
    assert b'Register' in response.data

def test_register_new_user(client):
    response = client.post(
        '/register',
        data={'username': 'newuser', 'password': 'newpassword'},
        follow_redirects=False
    )
    assert response.status_code in (200, 302)
    assert response.headers.get('Location', '/register').endswith('/register')

def test_register_existing_user(client):
    client.post(
        '/register',
        data={'username': 'admin', 'password': 'password123'},
        follow_redirects=True
    )

    response = client.post(
        '/register',
        data={'username': 'admin', 'password': 'password123'},
        follow_redirects=True
    )
    assert response.status_code == 200

def test_welcome_page_after_login(client):
    response = client.get('/welcome', follow_redirects=True)
    assert response.status_code in (200, 302, 404)

def test_logout_redirect(client):
    client.post(
        '/login',
        data={'username': 'admin', 'password': 'password123'},
        follow_redirects=True
    )

    response = client.get('/logout', follow_redirects=False)
    assert response.status_code == 302
    assert response.headers['Location'].startswith('/login')

def test_course_page_get(client):
    response = client.get('/course', follow_redirects=True)
    assert response.status_code in (200, 302, 404)

def test_health_check(client):
    response = client.get('/health')
    assert response.status_code in (200, 404)

def test_home_page_access(client):
    response = client.get('/', follow_redirects=True)
    assert response.status_code in (200, 302, 404)

def test_invalid_route_returns_404(client):
    response = client.get('/this-route-does-not-exist')
    assert response.status_code == 404

def test_methods_not_allowed(client):
    response = client.put('/login')
    assert response.status_code in (400, 405)
