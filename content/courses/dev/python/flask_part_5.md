---
title: "Flask - Part 5"
description: "Authentification with JWT"
date: 2018-09-25
githubIssueID: 0
tags: ["flask", "jwt"]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

---

## Introduction

This `version_5` will show you how to implement `JWT` to authentify your users.

### Concepts

- jwt
- decorators

---

## Setting up

To begin we will start from our previous version_4 app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
$ cp flask_cybermooc/version_4 my_app_v5
$ cd my_app_v5
```

<pre>
flask_learning
│
├── flask_cybermooc
│	├── version_1	
│	├── version_2
│	├── version_3
│   ├── version_4
│   ├── version_5   # reference code
│   └── version_XXX	
├── my_app_v1
├── my_app_v2
├── my_app_v3
├── my_app_v4
└── my_app_v5 (*)   # your folder
</pre>

your `my_app_v5` folder should look like this :

<pre>
my_app_v5
│
├── .editorconfig
├── .env
├── requirements.txt
├── __init__.py         # application factory
├── bcrypt.py
├── cli.py
├── database.py
├── api_v1 				
│	├── __init__.py
│   ├── hello.py
│   └── user.py         # login & signup routes
└── models
    ├── __init__.py
    └── user.py
</pre>

Let's create our venv.

```bash
# assuming you're in flask_learning/my_app_v5
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install -r requirements.txt
```

All set up ? let's begin.

---

## JWT

JWT (JSON Web Token)([more details here](https://jwt.io/introduction/)) is a JSON Object digitaly signed that carries data and is use to authentify users and services. The JWT is issued by the server and the client send it everytime it requests the server. The JWT is placed inside the `headers` of the request in the `Authentification` field.

### Installing JWT

We actually don't need to install anything because Flask is shipped with `itsdangerous` which has a JWT module.

- Why using a JWT instead of Session ?
    - [link 1](https://ponyfoo.com/articles/json-web-tokens-vs-session-cookies)
    - [link 2](https://stackoverflow.com/a/45214431)

---

### Adding JWT to our app

So basically a JWT keeps data, and is signed by the server. The data stored inside the JWT is called `claims`. 

TO sign the JWT, we first need to create a `SECRET_KEY`.

We will store this secret key inside the `.env` file. A good way to generate this secret key is to use a unique uuid. The following command will generate a random uuid.

```python
python3 -c 'from uuid import uuid4; print(uuid4())'
```

So let's change `.env` to add our `SECRET_KEY`.

```bash
DATABASE_URL=sqlite:///db.sqlite
SECRET_KEY=ad132b10-fa43-4048-ae5b-ab5b0a782c5c
```

Let's create a file to host our jwt factory:

```bash
# assuming you're in flask_learning/my_app_v5
(venv) $ touch jwt.py
```

and add this code :

```python
# jwt.py

from itsdangerous import (
    TimedJSONWebSignatureSerializer
    as Serializer, BadSignature, SignatureExpired
)

def generate_jwt(claims, expiration = 172800):
    from os import environ as env
    s = Serializer(env.get('SECRET_KEY'), expires_in = expiration)
    return s.dumps(claims).decode('utf-8')
```

Now that we have a function to generate a JWT, let's use it inside our login route.

Modify the `api_v1/user.py` file :

```python
# api_v1/user.py

from flask import (
    jsonify, request
)

from . import api_v1_blueprint

from ..bcrypt import bc
from ..database import db
from ..jwt import generate_jwt

from ..models.user import User

# [...] signup route

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
            claims = {'id': user.id}
            jwt = generate_jwt(claims)
            return jsonify(token=jwt),200
        return jsonify(error="password incorrect"),401
    return jsonify(error="username incorrect"),404
```

Here we imported our JWT file and changed the login route, to modify the return when the login is successful.

### Testing

Let's run our app :

```bash
(venv) $ FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

- Postman :

    ![v5 postman login example](/img/courses/dev/python/flask/v5_postman.png)

- HTTPie :

    ![v5 httpie login example](/img/courses/dev/python/flask/v5_httpie.png)

We can see that we got a token in return. So, we can now use this **token** to authenticate ourselves with the API. :-)

---

## Conclusion

If you have trouble making it work, please go to `flask_learning/flask_cybermooc/version_5` to see the reference code. And use `reset.sh` or `reset.bat` to launch it.

Otherwise, **congratulations** ! You just learned about JWT and how to generate and use them :-)

In the next part, we will add roles to our users (like admin), and use our JWT to authenticate ourselves and create some routes that require certain roles to access.

Let's go to [part 6](/courses/dev/python/flask_part_6/).
