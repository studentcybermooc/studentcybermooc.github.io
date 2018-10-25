---
title: "Flask - Part 4"
description: "Adding users and login/signup routes"
date: 2018-09-24
githubIssueID: 21
tags: ["flask", "sqlalchemy"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: false
---

## Introduction

This `version_4` will show you how to create signup and login routes.


### Setting up

To begin we will start from our previous version_3 app. If you don't have it anymore, no worries, simply copy the reference code :

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_3 my_app_v4
cd my_app_v4
```

and initialize our venv :

```bash
# assuming you're in flask_learning/my_app_v4
virtualenv venv -p python3
source venv/bin/activate
# (venv)
pip install -r requirements.txt # install from the requirements.txt file
```

All set up ? let's begin.

## 1 - Bcrypt

Because we will store passwords, we need to store them properly. (no md5 is not a proper way to store password). We will use the [bcrypt algorithm](https://en.wikipedia.org/wiki/Bcrypt).

### 1.1 - Installing bcrypt

In our venv, let's install `flask-bcrypt` which contains bcrypt + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
pip install flask-bcrypt
pip freeze > requirements.txt
```

### 1.2 - Adding bcrypt to our app

Now that bcrypt is installed, we need to tell our app to use bcrypt when it starts.

It’s a good idea to keep the Marshmallow object instance in a separate file, to avoid [circular imports](https://en.wikipedia.org/wiki/Circular_dependency).

To do so, let's create the marshmallow file :

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
touch app/bcrypt.py
```

and add this code :

```python
# bcrypt.py

from flask_bcrypt import Bcrypt

bc = Bcrypt()
```

In the application_factory `__init__.py`, let's update our code :

```python
# app/__init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    
    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    from .database import db
    db.init_app(app)

    from .bcrypt import bc
    bc.init_app(app)

    from .cli import cli_init_app
    cli_init_app(app)

    from .api_v1 import api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

`Bcrypt` is now imported and initialized.


## 2 - Updating our model

In `app/models/user.py` we can now add some methods to use bcrypt.

```python
# models/user.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from .base import Base
from ..bcrypt import bc
from ..database import db


class User(Base):

    __tablename__ = 'users'

    username = db.Column(db.String, nullable=False, unique=True)
    email = db.Column(db.String, nullable=False, unique=True)
    encrypted_password = db.Column(db.String, nullable=False)

    def set_password(self, password):
        self.encrypted_password = bc.generate_password_hash(password)

    def verify_password(self, password):
        return bc.check_password_hash(self.encrypted_password, password)
```

## 4 - Creating our routes

In `app/api_v1`, let's create a file `user.py` for the routes of the user :

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
touch app/api_v1/user.py
```

We import those routes in our module `app/api_v1/__init__.py`.

```python
# app/api_v1/__init__.py

from flask import Blueprint

root_blueprint = Blueprint('api_v1', __name__)
api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Import any endpoints here to make them available
from . import hello
from . import user
```

### 4.1 - Signup route

To signup, the route will receive a username, an email and a password.

In `app/api_v1/user.py`

```python
# app/api_v1/user.py

from flask import (
    jsonify, request
)
from . import api_v1_blueprint
from ..database import db
from ..models.user import User


@api_v1_blueprint.route('/signup', methods=['POST'])
def signup():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),422
    email = datas.get('email','')
    if email is '':
        return jsonify(error="email is empty"),422
    # we could verify that this email is valid
    password = datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),422
    if User.query.filter(User.username == username).first() is not None:
        return jsonify(err="username already taken"), 409
    if User.query.filter(User.email == email).first() is not None:
        return jsonify(err="email already signed-up"), 409
    new_user = User()
    new_user.username = username
    new_user.email = email
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()
    return jsonify(msg="welcome :-)"), 200
```

Explaining :
- line 15 : reading the json we received
- lines 17 to 26 : checking that the differents JSON fields are correct (not empty etc...)
- lines 27-28 : calling the controller to create the user
- line 29 : if the controller does not raise any exception, we can proceed
- lines 30-31 : return the error

#### 4.1.1 - Adding the unit test

In our folder `tests`, let's add a file `test_2_signup_route.py` : (we add a number to order the tests)

```python
# tests/test_2_signup_route.py


def test_signup_empty_password(client):
    # testing errors
    empty_password = client.post("/api/v1/signup", json={
        'username': 'testuser', 'password': '', 'email': 'test_user@mail.com'
    })
    assert empty_password.status_code == 422

def test_signup_empty_username(client):
    empty_username = client.post("/api/v1/signup", json={
        'username': '', 'password': 'test_user', 'email': 'test_user@mail.com'
    })
    assert empty_username.status_code == 422

def test_signup_empty_email(client):
    empty_email = client.post("/api/v1/signup", json={
        'username': 'testuser', 'password': 'test_user', 'email': ''
    })
    assert empty_email.status_code == 422

def test_signup_correct(client):
    correct = client.post("/api/v1/signup", json={
        'username': 'testuser', 'password': 'test_user', 'email': 'test_user@mail.com'
    })
    assert correct.status_code == 200

def test_signup_username_taken(client):
    username_taken = client.post("/api/v1/signup", json={
        'username': 'testuser', 'password': 'test_user', 'email': 'test_user@mail.com'
    })
    assert username_taken.status_code == 409

def test_signup_email_taken(client):
    email_taken = client.post("/api/v1/signup", json={
        'username': 'testuser', 'password': 'test_user', 'email': 'test_user@mail.com'
    })
    assert email_taken.status_code == 409
```

![v4 unittest](/img/courses/dev/python/flask_part_4/v4_unittest_signup.png)

#### 4.1.2 - Testing this signup route

Let's run our app, initiate the database and test this route :-)

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
flask reset-db
flask run
```

- Postman :

    ![v4 postman signup example](/img/courses/dev/python/flask_part_4/v4_postman_signup.png)

    **Success**, it's working great :)

    And if we try to signup again with the same username :

    ![v4 postman signup error](/img/courses/dev/python/flask_part_4/v4_postman_signup_error.png)

    We got our error back. Great !

- HTTPie :

    ![v4 httpie signup example](/img/courses/dev/python/flask_part_4/v4_httpie_signup.png)

    **Success**, it's working great :)

    And if we try to signup again with the same username :

    ![v4 httpie signup error](/img/courses/dev/python/flask_part_4/v4_httpie_signup_error.png)

    We got our error back. Great !

Perfect, our app is working great :)

A quick check inside the database to be sure the data is stored :

![v4 sqlitebrowser check](/img/courses/dev/python/flask_part_4/v4_sqlite_check.png)

The password is encrypted and our user is there, no problem !


### 4.2 - Login

In `app/api_v1/user.py`, at the end of the file, let's add our login route :

```python
# app/api_v1/user.py

[...]

@api_v1_blueprint.route('/login', methods=['POST'])
def login():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),422
    password = datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),422
    user = User.query.filter(User.username == username).first()
    if user is not None:
        if user.verify_password(password):
            return jsonify(msg="welcome"), 200
        return jsonify(err="password incorrect"), 401
    return jsonify(err="username incorrect"), 404
```

#### 4.2.1 - Adding the unit test

In our folder `tests`, let's add a file `test_3_login_route.py` : (we add a number to order the tests)

```python
# tests/test_3_login_route.py

def test_empty_password(client):
    # testing errors
    empty_password = client.post("/api/v1/login", json={
        'username': 'testuser', 'password': ''
    })
    assert empty_password.status_code == 422

def test_empty_username(client):
    empty_username = client.post("/api/v1/login", json={
        'username': '', 'password': 'test_user'
    })
    assert empty_username.status_code == 422

def test_correct(client):
    correct = client.post("/api/v1/login", json={
        'username': 'testuser', 'password': 'test_user'
    })
    assert correct.status_code == 200

def test_wrong_username(client):
    wrong_username = client.post("/api/v1/login", json={
        'username': 'testusernot', 'password': 'test_user'
    })
    assert wrong_username.status_code == 404

def test_wrong_password(client):
    wrong_password = client.post("/api/v1/login", json={
        'username': 'testuser', 'password': 'test_user_wrong'
    })
    assert wrong_password.status_code == 401
```

![v4 unittest](/img/courses/dev/python/flask_part_4/v4_unittest_login.png)

#### 4.2.1 - Testing this login route

Let's run our app :

```bash
# assuming you're in flask_learning/my_app_v4 (venv )
flask run 
```

- `Postman` :

Success :

![v4 postman login example](/img/courses/dev/python/flask_part_4/v4_postman_login.png)

Fail :

![v4 postman login error](/img/courses/dev/python/flask_part_4/v4_postman_login_error.png)

- `HTTPie` :

Success :

![v4 httpie login example](/img/courses/dev/python/flask_part_4/v4_httpie_login.png)

Fail :

![v4 httpie login error](/img/courses/dev/python/flask_part_4/v4_httpie_login_error.png)

## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_4` to see the reference code. And use `run.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to create two main routes "login" and "signup". (well your users aren't technically logged-in but still)

If you understood everything, in [part 5](/courses/dev/python/flask_part_5/) you will see how to use [JSON Web Tokens](https://jwt.io/introduction/), a cool way to authentify your users.
