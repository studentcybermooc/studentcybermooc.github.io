---
title: "Flask - Part 8"
description: "Token whitelisting"
date: 2018-09-28
githubIssueID: 0
tags: ["flask", "jwt"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---

## Introduction

This `version_8` will show you how to implement whitelisting. 

Whitelisting is defining what is allowed, and rejecting everything else. In our case, we will store the user's tokens in DB so the user can manage them (that's how facebook does it, with one token per device [lol](https://thehackernews.com/2018/09/facebook-account-hacked.html)).


### Setting up

To begin we will start from our previous `version_7` app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_7 my_app_v8
cd my_app_v8
```

and we create our venv.

```bash
# assuming you're in flask_learning/my_app_v8
virtualenv venv -p python3
source venv/bin/activate
# (venv)
pip install -r requirements.txt
```

All set up ? let's begin.


## 1 - Declaring the Token

We will create a basic Token model, but you can update it with more fields in your next project.

Here's an example by whatsapp where they store if the token is active, the OS, location etc... And that's why whitelisting is useful, because you can log out from every device.

![v8 whatsapp tokens sessions](/img/courses/dev/python/flask_part_8/v8_whatsapp.jpg)


### 1.1 - Creating the token model

So let's create our model in `models/token.py`.

```python
# models/token.py

from .base import Base
from ..database import db

class Token(Base):

    __tablename__ = 'tokens'

    hash = db.Column(db.String, nullable=False, unique=True)
    description = db.Column(db.String)
    user_id = db.Column(db.Integer,
                        db.ForeignKey('users.id'),
                        nullable=False)
```

Pretty straight forward, inheriting from Base, + more fields like the hash of the token, an optional description and the user's id.

Let's import this model in the cli :

```python
# cli.py

import click
from flask.cli import with_appcontext
from .controllers.user import user_signup
from .database import db


@click.command('reset-db')
@with_appcontext
def reset_db_command():
    """Clear existing data and create new tables."""
    # run it with : FLASK_APP=. flask reset-db
    from .models.association import user_roles
    from .models.user import User
    from .models.role import Role
    from .models.token import Token
    db.drop_all()
    db.create_all()
    click.echo('The database has been reset.')

[...]
```

Now let's update our User model.

```python
# models/user.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from .association import user_roles
from .role import Role
from .token import Token
from .base import Base
from ..bcrypt import bc
from ..database import db


class User(Base):

    __tablename__ = 'users'

    username = db.Column(db.String, nullable=False, unique=True)
    email = db.Column(db.String, nullable=False, unique=True)
    encrypted_password = db.Column(db.String, nullable=False)

    roles = db.relationship(Role, secondary=user_roles,
                            backref=db.backref('users', lazy='dynamic'))
    tokens = db.relationship(Token, backref="user")

    def has_role(self, role):
        if isinstance(role, str):
            # if role is the name of the role and not the object
            return role in (role.name for role in self.roles)
        else:
            return role in self.roles

    def set_password(self, password):
        self.encrypted_password = bc.generate_password_hash(password)

    def verify_password(self, password):
        return bc.check_password_hash(self.encrypted_password, password)
```

- Line 16 : we declared a `tokens` field to get the user's tokens.

### 1.1 - Testing

Let's reset our database to make sure the tables and associations are created.

```bash
# assuming you're in flask_learning/my_app_v8
(venv) $ FLASK_APP=. flask reset-db
```

![v8 sqlite browser](/img/courses/dev/python/flask_part_8/v8_sqlite_browser.png)

Looks good :-) Let's add the logic now.

## 2 - Token whitelisting implementation

### 2.1 - Creating a new token

Let's add a new function in our `user` controller.

```python
# controllers/user.py

from ..database import db
from ..jwt import generate_jwt
from ..models import (
    User, Token
)

[...]

def user_get_auth_token(current_user):
    claims = {'user_id' : current_user.id}
    jwt = generate_jwt(claims)
    token = Token()
    token.hash = jwt
    token.description = "could be location or something idk"
    token.user_id = current_user.id
    db.session.add(token)
    db.session.commit()
    return jwt
```

This function simply generate a token, and add it to the user's tokens list.

We will call this function in our `login` route.

```python
# api_v1/user.py

from flask import (
    jsonify, request
)
from . import api_v1_blueprint
from ..bcrypt import bc
from ..controllers.user import (
    user_signup, user_login
)
from ..database import db

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
        current_user = user_login(username, password)
        jwt = user_get_auth_token(current_user)
        return jsonify(token=jwt),200
    except Exception as err:
        return jsonify(err=str(err)),401

[...]
```

Here we simply replaced our previous `jwt = connected_user.get_auth_token()` by `jwt = user_get_auth_token(connected_user)`.

Now everytime a user log-in, the newly created token is added to the whitelist. 

### 2.2 - Verify the token

Let's now implement the verification. For that we need to update our `valid_token_required` decorator.

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
        for token in current_user.tokens:
            if token.hash == jwt:
                return fn(current_user=current_user, *args, **kwargs)
        return jsonify(err="token is not valid"),401
    return wrapped

[...]
```

The decorator now checks if the token is in the user's tokens list. If not, it fails.

### 2.3 - Testing

```bash
# assuming you're in flask_learning/my_app_v8 (venv)
FLASK_APP=. flask reset-db
FLASK_APP=. flask create-admin 'root' 'root@mail.com' 'toor'
FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

- with a non-whitelisted token :

![v8 token invalid](/img/courses/dev/python/flask_part_8/v8_postman_token_invalid.png)

- with a whitelisted token :

![v8 token whitelisted](/img/courses/dev/python/flask_part_8/v8_postman_token_whitelisted.png)

Working great :-)


## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_8` to see the reference code. And use `reset.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to implement token whitelisting.

You're now ready to go to [part 9](/courses/dev/python/flask_part_9/) to learn how a user can revoke some of its tokens.
