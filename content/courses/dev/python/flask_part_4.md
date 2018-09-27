---
title: "Flask - Part 4"
description: "Flask Users routes + roles"
date: 2018-09-24
githubIssueID: 0
tags: ["flask", "sqlalchemy"]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

## Table of contents

- [Introduction](#introduction)
  * [Concepts](#concepts)
- [Setting up](#setting-up)
- [SQLAlchemy](#sqlalchemy)
  * [Installing sqlalchemy](#installing-sqlalchemy)
  * [Adding sqlalchemy to our app](#adding-sqlalchemy-to-our-app)
- [Adding models](#adding-models)
  * [Generating the database](#generating-the-database)
  * [Testing](#testing)
- [Conclusion](#conclusion)

---

## Introduction

This `version_4` will show you how to create signup and login routes. And an introduction to JWT.

### Concepts

- flask routes
- JWT

---

## Setting up

To begin we will start from our previous version_3 app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_3 my_app_v4
cd my_app_v4
```

<pre>
flask_learning
│
├── flask_cybermooc
│	├── version_1	
│	├── version_2
│	├── version_3
│   ├── version_4   # reference code
│   └── version_XXX	
├── my_app_v1
├── my_app_v2
├── my_app_v3
└── my_app_v4 (*)   # your folder
</pre>

your `my_app_v4` folder should look like this :

<pre>
my_app_v4
│
├── .editorconfig
├── .env
├── requirements.txt
├── __init__.py
├── cli.py
├── database.py
├── api_v1 				
│	├── __init__.py
│   └── hello.py
└── models
    ├── __init__.py
    └── user.py
</pre>

Let's create our venv.

```bash
# assuming you're in flask_learning/my_app_v4
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install -r requirements.txt # install from the requirements.txt file
```

All set up ? let's begin.

---

## Bcrypt

Because we will store passwords, we need to store them properly. (no md5 is not a proper way to store password). We will use the [bcrypt algorithm](https://en.wikipedia.org/wiki/Bcrypt).

### Installing bcrypt

In our venv, let's install `flask-bcrypt` which contains bcrypt + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ pip install flask-bcrypt
(venv) $ pip freeze > requirements.txt
```

---

### Adding bcrypt to our app

Now that bcrypt is installed, we need to tell our app to use bcrypt when it starts.

It’s a good idea to keep the Marshmallow object instance in a separate file, to avoid [circular imports](https://en.wikipedia.org/wiki/Circular_dependency).

To do so, let's create the marshmallow file :

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ touch bcrypt.py
```

and add this code :

```python
# bcrypt.py

from flask_bcrypt import Bcrypt

bc = SQLAlchemy()
```

Then in your application_factory `__init__.py`, let's modify our code like this :

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

Here we just imported bcrypt and added it to our app.

---

## Adding routes

In our `api_v1` folder, let's add a `user.py` file to write our routes.

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ touch api_v1/user.py
```

We don't forget to link this in  `api_v1/__init__.py`.

```python
# api_v1/__init__.py

from flask import Blueprint

api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Import any endpoints here to make them available
from . import hello
from . import user
```

Let's see how a route works.

### Signup

As we're doing a REST API, we should apply the REST principles.

Our API will receive and return JSON.

So to signup, we should receive a username, an email and a password.

If the username is not taken, the email not already used and the password not empty, the user will be created. Otherwise it will fail and we will return an error.

The password will be encrypted before storage so we will need bcrypt. To store into the database we will need our sqlalchemy instance. And to create a user we will need the User model.

In `api_v1/user.py`

```python
# api_v1/user.py

from flask import (
    jsonify, request
)

from . import api_v1_blueprint

from ..database import db
from ..bcrypt import bc

from ..models.user import User

@api_v1_blueprint.route('/users/signup', methods=['POST'])
def signup():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),400
    # we could add some filters to our username
    email=datas.get('email','')
    if email is '':
        return jsonify(error="email is empty"),400
    # we could verify that this email is valid
    password=datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),400
    # we could add a password policy (a good one please)

    if User.query.filter(User.username == username).first() is not None:
        return jsonify(error="username already used"),400

    if User.query.filter(User.email == email).first() is not None:
        return jsonify(error="email already used"),400

    u = User()
    u.username = username
    u.email = email
    u.encrypted_password = bc.generate_password_hash(password)

    db.session.add(u)
    db.session.commit()
    return jsonify(msg="welcome :-)"),200
```

Explaining :
- lines 3 to 12 : importing what we need
- line 16 : reading the json we received
- lines 17 to 27 : checking that the JSON is correct (not empty etc...)
- lines 30 to 34 : checking the the username or email is not already used
- lines 36 to 39 : creating the User object to be stored into the database, encrypting the password
- lines 41-42 : storing the object into the database
- line 43 : all good we return a message

---

#### Testing this signup route

Let's run our app, initiate the database and test this route :-)

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ FLASK_APP=. flask reset-db
(venv) $ FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

- Postman :

    ![v4 postman signup example](/img/courses/dev/python/flask/v4_postman_signup.png)

    **Success**, it's working great :)

    And if we try to signup again with the same username :

    ![v4 postman signup error](/img/courses/dev/python/flask/v4_postman_signup_error.png)

    We got our error back. Great !

- HTTPie :

    ![v4 httpie signup example](/img/courses/dev/python/flask/v4_httpie_signup.png)

    **Success**, it's working great :)

    And if we try to signup again with the same username :

    ![v4 httpie signup error](/img/courses/dev/python/flask/v4_httpie_signup_error.png)

    We got our error back. Great !

Perfect, our app is working great :)

A quick check inside the database to be sure the data is stored :

![v4 sqlitebrowser check](/img/courses/dev/python/flask/v4_sqlite_check.png)

The password is encrypted and our user is there, no problem !

---

### Login

In `api_v1/user.py`, at the end of the file, let's add our login route :

```python
# api_v1/user.py

[...]


@api_v1_blueprint.route('/users/login', methods=['POST'])
def login():
    datas = request.get_json()
    login_username = datas.get('username','')
    if login_username is '':
        return jsonify(error="username is empty"),400
    login_password = datas.get('password','').encode('utf-8')
    if login_password is '':
        return jsonify(error="password is empty"),400
    user = User.query.filter(User.username == login_username).first()
    if user is not None:
        if bc.check_password_hash(user.encrypted_password, login_password):
            return jsonify(msg="you are now connected (well you don't but hey)"),200
        return jsonify(error="password incorrect"),401
    return jsonify(error="username incorrect"),404
```

---

#### Testing this login route

Let's run our app :

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

- Postman :

    ![v4 postman login example](/img/courses/dev/python/flask/v4_postman_login.png)

    **Success**, it's working great :)

    And if we fail the password :

    ![v4 postman login error](/img/courses/dev/python/flask/v4_postman_login_error.png)

    We got our error back. Great !

- HTTPie :

    ![v4 httpie login example](/img/courses/dev/python/flask/v4_httpie_login.png)

    **Success**, it's working great :)

    And if we fail the password :

    ![v4 httpie login error](/img/courses/dev/python/flask/v4_httpie_login_error.png)

    We got our error back. Great !

---

## Conclusion

If you have trouble making it work, please go to `flask_learning/flask_cybermooc/version_4` to see the reference code. And use `reset.sh` or `reset.bat` to launch it.

Otherwise, **congratulations** ! You just learned how to create two main routes "login" and "signup". (well your users aren't technically signed-up but still)

If you understood everything, in [part 5](/courses/dev/python/flask_part_5/) you will see how to use [JSON Web Tokens](https://jwt.io/introduction/), a cool way to authentify your users.
