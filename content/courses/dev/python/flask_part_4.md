---
title: "Flask - Part 4"
description: "Flask Users routes + roles"
date: 2018-09-24
githubIssueID: 0
tags: ["flask", "sqlalchemy"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
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
touch bcrypt.py
```

and add this code :

```python
# bcrypt.py

from flask_bcrypt import Bcrypt

bc = Bcrypt()
```

In the application_factory `__init__.py`, let's update our code :

```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    
    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')

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

In `models/user.py` we can now add some methods to use bcrypt.

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

## 3 - Creating our controller

A controller contains the logic that will manipulate the model.

Let's create a `controllers` folder :

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
mkdir controllers
```

And add the controller of the user :

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
touch controllers/user.py
```

Then we code :

```python
# controllers/user.py

from ..database import db
from ..models.user import User


def user_signup(username, email, password):
    if User.query.filter(User.username == username).first() is not None:
        raise Exception("username already taken")
    if User.query.filter(User.email == email).first() is not None:
        raise Exception("email already signed-up")
    new_user = User()
    new_user.username = username
    new_user.email = email
    new_user.set_password(password)
    db.session.add(new_user)
    db.session.commit()
    return new_user


def user_login(username, password):
    user = User.query.filter(User.username == username).first()
    if user is not None:
        if user.verify_password(password):
            return user
        raise Exception("password incorrect")
    raise Exception("username incorrect")
```

## 4 - Creating our routes

In `api_v1`, let's create a file `user.py` for the routes of the user :

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
touch api_v1/user.py
```

We import those routes in our module `api_v1/__init__.py`.

```python
# api_v1/__init__.py

from flask import Blueprint

api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Import any endpoints here to make them available
from . import hello
from . import user
```

### 4.1 - Signup route

To signup, the route will receive a username, an email and a password.

In `api_v1/user.py`

```python
# api_v1/user.py

from flask import (
    jsonify, request
)
from . import api_v1_blueprint
from ..controllers.user import user_signup, user_login
from ..database import db

@api_v1_blueprint.route('/users/signup', methods=['POST'])
def signup():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),400
    # we could add some filters to our username
    email = datas.get('email','')
    if email is '':
        return jsonify(error="email is empty"),400
    # we could verify that this email is valid
    password = datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),400
    try:
        new_user = user_signup(username, email, password)
        return jsonify(msg="welcome :-)"),200
    except Exception as err:
        return jsonify(err=str(err)),401
```

Explaining :
- line 15 : reading the json we received
- lines 17 to 26 : checking that the differents JSON fields are correct (not empty etc...)
- lines 27-28 : calling the controller to create the user
- line 29 : if the controller does not raise any exception, we can proceed
- lines 30-31 : return the error

#### 4.1.1 - Testing this signup route

Let's run our app, initiate the database and test this route :-)

```bash
# assuming you're in flask_learning/my_app_v4 (venv)
FLASK_APP=. flask reset-db
FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
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

In `api_v1/user.py`, at the end of the file, let's add our login route :

```python
# api_v1/user.py

[...]


@api_v1_blueprint.route('/users/login', methods=['POST'])
def login():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),400
    password = datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),400
    try:
        with user_login(username, password) as connected_user:
            return jsonify(msg="welcome :-)"),200
    except Exception as err:
        return jsonify(err=str(err)),401
```

#### 4.2.1 - Testing this login route

Let's run our app :

```bash
# assuming you're in flask_learning/my_app_v4 (venv )
FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
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

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_4` to see the reference code. And use `reset.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to create two main routes "login" and "signup". (well your users aren't technically signed-up but still)

If you understood everything, in [part 5](/courses/dev/python/flask_part_5/) you will see how to use [JSON Web Tokens](https://jwt.io/introduction/), a cool way to authentify your users.
