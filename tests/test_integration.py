import requests

def test_home_route():
    response = requests.get('http://flask_app:5000')
    assert response.status_code == 200
    assert response.json() == {'message': 'Hello, World!'}

if __name__ == '__main__':
    test_home_route()
