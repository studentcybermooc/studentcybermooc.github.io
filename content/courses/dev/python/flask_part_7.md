---
title: "Flask - Part 7"
description: "Restricting access to routes"
date: 2018-09-25
githubIssueID: 0
tags: ["flask", "sqlalchemy", "jwt"]
draft: true
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