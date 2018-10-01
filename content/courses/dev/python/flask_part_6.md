---
title: "Flask - Part 6"
description: "Restricting access to routes"
date: 2018-09-25
githubIssueID: 0
tags: ["flask", "sqlalchemy", "jwt"]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

## Introduction

This `version_6` will show you how to add roles to your users and how to restrict access to routes to certain roles.

### Concepts

- jwt
- decorators

---

## Setting up

To begin we will start from our previous `version_5` app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_5 my_app_v6
cd my_app_v6
```

<pre>
flask_learning
│
├── flask_cybermooc
│	├── version_1	
│	├── version_2
│	├── version_3
│   ├── version_4
│   ├── version_5
│   ├── version_6   # reference code
│   └── version_XXX	
├── my_app_v1
├── my_app_v2
├── my_app_v3
├── my_app_v4
├── my_app_v5
└── my_app_v6 (*)   # your folder
</pre>

your `my_app_v6` folder should look like this :

<pre>
my_app_v6
│
├── .editorconfig
├── .env
├── requirements.txt
├── __init__.py
├── bcrypt.py
├── cli.py
├── database.py
├── jwt.py
├── api_v1 				
│	├── __init__.py
│   ├── hello.py
│   └── user.py
└── models
    ├── __init__.py
    ├── role.py
    └── user.py
</pre>

Let's create our venv.

```bash
# assuming you're in flask_learning/my_app_v6
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install -r requirements.txt
```

All set up ? let's begin.

---

## Roles

Roles are a crucial part in an application. You can apply [the principle of least privilege](https://fr.wikipedia.org/wiki/Principe_de_moindre_privil%C3%A8ge), eg. every new user has no role. You can also create a role-based permission management and even add capabilities (view-X, edit-X, delete-X).

### Adding roles

To create roles we need to create a model, in `models/role.py`.

```bash
(venv) $ touch models/role.py
```

and code our role model :

```python
# models/role.py

from ..database import db

class Role(db.Model):
    __tablename__ = 'roles'
    #fields
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), unique=True)
    description = db.Column(db.String(255))

    # methods
    def __eq__(self, other):
        return (self.name == other or
                self.name == getattr(other, 'name', None))

    def __ne__(self, other):
        return not self.__eq__(other)
```

then update our `models/user.py` model :

```python
# models/user.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from ..bcrypt import bc
from ..database import db
from ..jwt import generate_jwt

class User(db.Model):
    __tablename__ = 'users'
    # fields
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String, nullable=False, unique=True)
    email = db.Column(db.String, nullable=False, unique=True)
    encrypted_password = db.Column(db.String, nullable=False)
    # associations
    roles = db.relationship('Role', secondary="roles_users",
                            backref=db.backref('users', lazy='dynamic'))

    #methods
    def has_role(self, role):
        if isinstance(role, str):
            return role in (role.name for role in self.roles)
        else:
            return role in self.roles

    def get_auth_token(self):
        claims = dict()
        claims['id'] = self.id
        claims['roles'] = [role.name for role in self.roles]
        return generate_jwt(claims)

    def set_password(self, password):
        self.encrypted_password = bc.generate_password_hash(password)

    def verify_password(self, password):
        return bc.check_password_hash(self.encrypted_password, password)
```

and add a file for our association tables `models/association.py` :

```python
# models/association.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from ..database import db

roles_users = db.Table('roles_users',
        db.Column('user_id', db.Integer, db.ForeignKey("users.id")),
        db.Column('role_id', db.Integer, db.ForeignKey("roles.id")))
```

Explanation : 
- line 15 : with sqlalchemy, we can declare a field that will be populate by this many-to-many relationship. It gives us a `list` of Roles, handy to `.append` etc...
- lines 19-end : new handy methods

Finally, update our module `models/__init__.py` :

```python
# models/__init__.py

# import all the models here
from .user import User
from .role import Role 
from .association import roles_users
```

- Btw, why do we need a module ?

    A module in our case, allow us to avoid circular imports.
    `__init__.py` is a special python file that will be automatically read.
    So by importing every model in this file, every other files in this folder will have access to every other one.

## Restructuring our app

We are going to create controllers to organize our code.

> **routes &harr; controllers &harr; models**

Let's create a `controllers` folder.

```bash
(venv) $ mkdir controllers
```

and inside let's create a `role.py` file :

```bash
(venv) $ touch controllers/user.py
```

Then we can (re)code 2 functions : register and login.

```python
# controllers/user.py

from flask import jsonify
from ..database import db
from ..models import User

def user_signup(username, email, password):
    if User.query.filter(User.username == username).first() is not None:
        return jsonify(error="username already used"),400

    if User.query.filter(User.email == email).first() is not None:
        return jsonify(error="email already used"),400

    u = User()
    u.username = username
    u.email = email
    u.set_password(password)

    db.session.add(u)
    db.session.commit()
    return jsonify(msg="welcome :-)"),200

def user_login(username, password):
    user = User.query.filter(User.username == username).first()
    if user is not None:
        if user.verify_password(password):
            jwt = user.get_auth_token()
            return jsonify(token=jwt),200
        return jsonify(error="password incorrect"),401
    return jsonify(error="username incorrect"),404
```

This allow us to simplify our routes `api_v1/user.py` :

```python
# api_v1/user.py

from flask import (
    jsonify, request
)

from . import api_v1_blueprint
from ..controllers.user import user_signup, user_login

@api_v1_blueprint.route('/users/signup', methods=['POST'])
def route_users_signup():
    datas = request.get_json()
    signup_username = datas.get('username','')
    if signup_username is '':
        return jsonify(error="username is empty"),400
    # we could add some filters to our username
    signup_email = datas.get('email','')
    if signup_email is '':
        return jsonify(error="email is empty"),400
    # we could verify that this email is valid
    signup_password = datas.get('password','')
    if signup_password is '':
        return jsonify(error="password is empty"),400
    # we could add a password policy (a good one please)
    return user_signup(signup_username, signup_email, signup_password)
    

@api_v1_blueprint.route('/users/login', methods=['POST'])
def route_users_login():
    datas = request.get_json()
    login_username = datas.get('username','')
    if login_username is '':
        return jsonify(error="username is empty"),400
    login_password = datas.get('password','').encode('utf-8')
    if login_password is '':
        return jsonify(error="password is empty"),400
    return user_login(login_username, login_password)
```

### Testing

Our app has not changed, it has just been reorganized. Let's just be sure about that.

```bash
(venv) $ FLASK_APP=. flask reset-db
(venv) $ FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```
(you will need to create a user as our DB schema changed)

![v6 httpie example](/img/courses/dev/python/flask/v6_httpie_testing.png)

Yep, still working :-)

## Initiate data

Now that we have roles, it would be useful to create an `admin` role and an admin user.

To do so, we will create a command (just like `reset-db`).

So let's add this command to `cli.py` :

```python
# cli.py

import click
from flask.cli import with_appcontext
from .database import db
from .models import *

@click.command('reset-db')
@with_appcontext
def reset_db_command():
    """Clear existing data and create new tables."""
    # run it with : FLASK_APP=. flask reset-db
    db.drop_all()
    db.create_all()
    click.echo('The database has been reset.')

@click.command('create-admin')
@click.argument('username')
@click.argument('email')
@click.argument('password')
@with_appcontext
def create_admin_command(username, email, password):
    # run it with : FLASK_APP=. flask create-first-admin 
    admin_role = Role.query.filter(Role.name == "admin").first()
    if admin_role is None:
        admin_role = Role()
        admin_role.name = 'admin'
        admin_role.description = "admin role"
        db.session.add(admin_role)
    admin_user = User()
    admin_user.username = username
    admin_user.email = email
    admin_user.set_password(password)
    admin_user.roles.append(admin_role)
    db.session.add(admin_user)
    db.session.commit()
    click.echo(username + " was created with admin role.")

def cli_init_app(app):
    app.cli.add_command(reset_db_command)
    app.cli.add_command(create_admin_command)
```

In this new command, we create the admin role (if it does not exist already), 

### Testing

![v6 create admin example](/img/courses/dev/python/flask/v6_create_admin.png)

## Conclusion

If you have trouble making it work, please go to `flask_learning/flask_cybermooc/version_3` to see the reference code. And use `reset.sh` or `reset.bat` to launch it.

Otherwise, **congratulations** ! You just learned how to connect a database to your app. But our app is quite useless right now, isn't it ?.. 

Don't worry, if you understood everything, you're now ready to go to [part 4](/courses/dev/python/flask_part_4/) to see how to add a signup, login and roles to your users !
