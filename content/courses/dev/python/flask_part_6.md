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

## Table of contents

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
cp flask_cybermooc/version_4 my_app_v5
cd my_app_v5
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
├── __init__.py
├── bcrypt.py
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
# assuming you're in flask_learning/my_app_v5
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install -r requirements.txt
```

All set up ? let's begin.

---

## Marshmallow

Marshmallow is an Object Serializer. Its purpose is to "translate" data (like json) into a Python Object and vice-versa. This tool will allow us to easily parse our User object into JSON (it's called `unmarshalling`) or to create a User object from JSON (called `marshalling`).

### Installing marshmallow

In our venv, let's install `flask-marshmallow` which contains sqlalchemy + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ pip install flask-marshmallow
(venv) $ pip freeze > requirements.txt
```

---

### Adding marshmallow to our app

Now that marshmallow is installed, we need to tell our app to use sqlachemy when it starts.

It’s a good idea to keep the Marshmallow object instance in a separate file, to avoid [circular imports](https://en.wikipedia.org/wiki/Circular_dependency).

To do so, let's create the marshmallow file :

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ touch marshmallow.py
```

and add this code :

```python
# marshmallow.py

from flask_marshmallow import Marshmallow

ma = Marshmallow()
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

    from .marshmallow import ma
    ma.init_app(app)

    from .cli import cli_init_app
    cli_init_app(app)

    from .api_v1 import api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

Here we just imported our marshmallow instance and plugged it with our app.

---

## Adding schemas

What's a schema btw ?

A schema is a way to tell marshmallow how to serialize/deserialize (marshal) our object. (which fields to take, which to exclude, etc...).

We can now create a folder dedicated to our schemas (schemas of our models).

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ mkdir schemas
```

Your folder should look like this:

<pre>
my_app_v4
│
├── .editorconfig
├── .env
├── requirements.txt
├── __init__.py
├── cli.py
├── database.py
├── marshmallow.py
├── api_v1              
│   ├── __init__.py
│   └── hello.py
├── models
│   ├── __init__.py
│   └── user.py
└── schemas
    ├── __init__.py
    └── user.py
</pre>

Here's the schema for our user :

```bash
# assuming you're in flask_learning/my_app_v4
(venv) $ touch schemas/user.py
```

and in `schemas/user.py` :

```python
# schemas/user.py
# https://marshmallow.readthedocs.io/en/3.0/quickstart.html
# https://marshmallow.readthedocs.io/en/3.0/extending.html
# https://marshmallow.readthedocs.io/en/latest/nesting.html

from marshmallow import fields
from ..marshmallow import ma
from ..models.user import User

class UserSchema(ma.ModelSchema):

    id = fields.Int()
    username = fields.String()
    email = fields.String()

user_schema = UserSchema()
users_schema = UserSchema(many=True)
```

This schema specifies the fields of the object we want to serialize/deserialize. (load/unload)((marshal/unmarshal))

---

### Generating the database

SQLAlchemy will generate the database and the tables based on our code. But we need a way to trigger this event.

You could choose to reset the database everytime your app restarts, but it's gonna lead to troubles.

We will rather use the command-cli provided by Flask. (and it's an excuse for me to show you how to use the cli).

Let's create a file called `cli.py` that will host all our commands.


```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ touch cli.py
```

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

def cli_init_app(app):
    app.cli.add_command(reset_db_command)
```

Here, we declare a `command` that will drop all the tables and re-create them.

In order for this command to be accessible, we need to modify our `__init__.py`.

```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')

    from .database import db
    db.init_app(app)

    from .cli import cli_init_app
    cli_init_app(app)

    from .api_v1 import api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

Lines 13-14 have changed to include our new command-cli.

We are now **ready** to test our brand new app.

---

### Testing

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ FLASK_APP=. flask reset-db
```

If the command succeeded, a `db.sqlite` file should have appeared, with a weight around 16Kb.

This means that your database and its tables were created.

To be sure, we can use a database browser. For SQLite, a great tool is [sqlite-browser](http://sqlitebrowser.org/).

![v3 sqlitebrowser example](/img/courses/dev/python/flask/v3_sqlitebrowser.png)

---

## Conclusion

If you have trouble making it work, please go to `flask_learning/flask_cybermooc/version_3` to see the reference code. And use `reset.sh` or `reset.bat` to launch it.

Otherwise, **congratulations** ! You just learned how to connect a database to your app. But our app is quite useless right now, isn't it ?.. 

Don't worry, if you understood everything, you're now ready to go to [part 4](/courses/dev/python/flask_part_4/) to see how to add a signup, login and roles to your users !
