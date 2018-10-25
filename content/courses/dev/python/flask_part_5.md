---
title: "Flask - Part 5"
description: "User authentication with Json Web Token"
date: 2018-09-25
githubIssueID: 23
tags: ["flask", "jwt"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: false
---


## Introduction

This `version_5` will show you how to manage the authentication of the users. I choose to show how to use `JWT`, you can also use [flask_login](https://flask-login.readthedocs.io/en/latest/) but this course won't cover it.


### Setting up

To begin we will start from our previous version_4 app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_4 my_app_v5
cd my_app_v5
```

and initialize our venv :

```bash
# assuming you're in flask_learning/my_app_v5
virtualenv venv -p python3
source venv/bin/activate
# (venv)
pip install -r requirements.txt
```

All set up ? let's begin.

## 1 - JWT

JWT (JSON Web Token)([more details here](https://jwt.io/introduction/)) is a JSON Object digitaly signed that carries data and is used to authentify users and services. The JWT is issued by the server and the client send it everytime it requests the server. The JWT is placed inside the `headers` of the request in the `Authorization` field.

### 1.1 - Installing JWT

Flask is shipped with a module named `itsdangerous` which has a JWT module.

- Why using a JWT instead of Session ?
    - [link 1 - json-web-tokens-vs-session-cookies](https://ponyfoo.com/articles/json-web-tokens-vs-session-cookies)
    - [link 2 - SO](https://stackoverflow.com/a/45214431)


### 1.2 - Adding JWT to our app

So basically a JWT keeps data, and is signed by the server. The data stored inside the JWT is called `claims`. 

To sign the JWT, we first need to create a `SECRET_KEY`.

We will store this `SECRET_KEY` inside the `.env` file. A good way to generate this `SECRET_KEY` is to use a unique uuid. The following command will generate a random uuid.

```python
python3 -c 'from uuid import uuid4; print(uuid4())'
```

So let's change `.env` to add our `SECRET_KEY`.

```bash
DATABASE_URL=sqlite:///db.sqlite
SECRET_KEY=ad132b10-fa43-4048-ae5b-ab5b0a782c5c
```

Let's create a file `jwt.py` for our JWT factory:

```bash
# assuming you're in flask_learning/my_app_v5 (venv)
touch app/jwt.py
```

and add some code :

```python
# app/jwt.py

from os import environ as env
from itsdangerous import (
    TimedJSONWebSignatureSerializer
    as Serializer, BadSignature, SignatureExpired
)

def generate_jwt(claims, expiration = 172800):
    s = Serializer(env.get('SECRET_KEY'), expires_in = expiration)
    return s.dumps(claims).decode('utf-8')

def load_jwt(token):
    s = Serializer(env.get('SECRET_KEY'))
    try:
        data = s.loads(token)
    except SignatureExpired as err:
        raise Exception(str(err))
    except BadSignature as err:
        raise Exception(str(err))
    return data

```

We can now simply return the token if the login route is requested.

Let's modify the `api_v1/user.py` file :

```python
# app/api_v1/user.py

from flask import (
    jsonify, request
)
from . import api_v1_blueprint
from ..bcrypt import bc
from ..database import db
from ..jwt import generate_jwt
from ..models.user import User

[...] signup route

@api_v1_blueprint.route('/login', methods=['POST'])
def login():
    datas = request.get_json()
    username = datas.get('username','')
    if username is '':
        return jsonify(error="username is empty"),422
    password = datas.get('password','')
    if password is '':
        return jsonify(error="password is empty"),422
    current_user = User.query.filter(User.username == username).first()
    if current_user is not None:
        if current_user.verify_password(password):
            claims = {'user_id' : current_user.id}
            jwt = generate_jwt(claims)
            return jsonify(token=jwt),200
        return jsonify(err="password incorrect"), 401
    return jsonify(err="username incorrect"), 404
```

Here we imported our JWT file and changed the login route, to modify the return when the login is successful.

### 1.3 - Updating our unit test

Now that we change our `login` route, we need to update the corresponding unit test in `tests/test_3_login_route.py` :

```python
# tests/test_3_login_route.py

[...]

def test_login_correct(client, global_data):
    correct = client.post("/api/v1/login", json={
        'username': 'testuser', 'password': 'test_user'
    })
    assert correct.status_code == 200
    json_data = correct.get_json()
    assert "token" in json_data
    global_data['token'] = json_data['token']

[...]
```

### 1.4 - Testing with Postman and HTTPie

Let's run our app :

```bash
# assuming you're in flask_learning/my_app_v5 (venv)
flask run 
```

- `Postman` :

![v5 postman login example](/img/courses/dev/python/flask_part_5/v5_postman.png)

- `HTTPie` :

![v5 httpie login example](/img/courses/dev/python/flask_part_5/v5_httpie.png)

We can see that we got a token in return. So, we can now use this **token** to authenticate ourselves with the API :-)

Now that the user can be authenticated by the token, let's see how to implement JWT verification.

## 2 - Route decoration with login required

A decorator is a function that is executed before the next function and can add context and data to this next function.

### 2.1 - Creating the decorator

Let's create a file with all our decorators in `api_v1/decorators.py` :

```bash
# assuming you're in flask_learning/my_app_v5 (venv)
touch api_v1/decorators.py
```

This decorator is called a `middleware`. When a route is decorated, all the decorators will be executed before the route. It allows us to add context to the route.

```python
# api_v1/decorators.py

from functools import wraps
from flask import (
    jsonify, request
)
from ..jwt import load_jwt
from ..models.user import User


def login_required(fn):
    @wraps(fn)
    def wrapped(*args, **kwargs):
        if 'Authorization' not in request.headers:
            return jsonify(err="no Authorization header found"),400
        try:
            jwt = request.headers['Authorization']
            claims = load_jwt(jwt)
        except Exception as err:
            return jsonify(err=str(err)),401
        if 'user_id' not in claims:
            return jsonify(err="token is not valid"),400
        current_user = User.query.get(claims['user_id'])
        if current_user is None:
            return jsonify(err="404 User not found"),400
        return fn(current_user=current_user, *args, **kwargs)
    return wrapped
```

Here we get the User via the `user_id` stored in the token. So our route now has a new parameter `current_user`. Pretty handy :-) (a french explanation about python decorators [here](http://gillesfabio.com/blog/2010/12/16/python-et-les-decorateurs/))

### 2.2 - Decorating a route

Let's now use this decorator to create a `login_required` route in `api_v1/hello.py`

```python
# api_v1/hello.py

from . import root_blueprint
from .decorators import login_required


@root_blueprint.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


@root_blueprint.route('/need_login', methods=['GET'])
@login_required
def route_need_login(current_user):
    return "if you see this, that means your token is valid"
```

The route `/api/v1/need_login` is accessible only if `login_required` succeeds, so if the user provides a valid token.

### 2.3 - Unit test

Let's create the file `tests/test_4_login_required.py` to add our unit test :

```python
# tests/test_4_login_required.py

def test_login_required(client, global_data):
    rv = client.get('/need_login',
        headers={'Authorization': global_data['token']}
    )
    assert rv.status_code == 200


def test_login_required_missing_token(client):
    rv = client.get('/need_login')
    assert rv.status_code == 400


def test_login_required_invalid_token(client):
    rv = client.get('/need_login',
        headers={'Authorization': "test.test.test"}
    )
    assert rv.status_code == 401
```

![v5 unittest](/img/courses/dev/python/flask_part_5/v5_unittest.png)

### 2.4 - Testing with Postman

Let's run our app :

```bash
# assuming you're in flask_learning/my_app_v5 (venv )
flask run
```

After signing-up, we login to get the token. We will then include this token in `Authorization` header.

- If we don't provide an Authorization header

![v5 jwt no auth](/img/courses/dev/python/flask_part_5/v5_no_token.png)

- If the token is not valid

![v5 jwt invalid](/img/courses/dev/python/flask_part_5/v5_token_invalid.png)

- If the token is valid :-)

![v5 jwt valid](/img/courses/dev/python/flask_part_5/v5_token_valid.png)


## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_5` to see the reference code. And use `run.sh` to launch it.

Otherwise, **congratulations** ! You just learned about JWT and how to generate and use them :-)

In the next part, we will add roles to our users (like admin), and use our JWT to authenticate ourselves and create some routes that require certain roles to access.

You're now ready to begin [part 6](/courses/dev/python/flask_part_6/) to learn how to add roles to the users.
