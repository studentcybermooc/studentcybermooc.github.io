---
title: "Flask - Part 3"
description: "Flask + SQLalchemy"
date: 2018-09-23
githubIssueID: 0
tags: ["flask", "python", "sqlalchemy", "orm"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---

## Introduction

This `version_3` will teach you how to connect your app with a database via `SQLAlchemy` and how to declare your models.

### Setting up

To begin we will start from our previous `version_2` app. If you don't have it anymore, no worries, simply copy the reference code :

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_2 my_app_v3
cd my_app_v3
```

and initialize our venv :

```bash
# assuming you're in flask_learning/my_app_v3
virtualenv venv -p python3
source venv/bin/activate
# (venv)
pip install -r requirements.txt
```

## 1 - SQLAlchemy

SQLAlchemy is a python ORM. If you don't know what an ORM is, here's a pretty rought exaplanation. AN ORM is an object representation of your database. A python object (eg. a 'User') represents a table in your database. It allows you to use methods like 'get', 'query', 'first' instead of writing pure SQL.

### 1.1 - Installing SQLAlchemy

Let' install `flask_sqlalchemy` which contains sqlalchemy + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
pip install flask-sqlalchemy
pip freeze > requirements.txt
```

### 1.2 - Adding SQLAlachemy to our app

It is a good idea to keep the SQLAlchemy object instance in a separate file, to avoid [circular imports](https://en.wikipedia.org/wiki/Circular_dependency).

Let's create a file for our SQLAlchemy object

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
touch database.py
```

and declare our database

```python
# database.py

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
```

Wen can now import `db` in the application_factory `__init__.py` :

```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'

    from .database import db
	db.init_app(app)

    from .api_v1 import api as api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

A couple of new things going on here :

- line 7 : in order to connect to the database, SQLAlchemy will look for `SQLALCHEMY_DATABASE_URI` inside the configuration of the app. Here we hard-code the url and choose to use a `sqlite` database with the name `db.sqlite` (more about hard-coding this kind of information in a minute)
- line 9 : we import our SQLALchemy instance and initialize our app with it.

[_nota bene_](https://fr.wikipedia.org/wiki/Nota_bene): you should never [hard-code](https://forum.wordreference.com/threads/hard-coded.105554/?hl=fr) the URL of the database in your code, this is a **bad** practice.

- why ? (not safe, not practical, bad pattern)
	1. if you commit your code on a public repository, everyone can see it. Here it's a simple sqlite, but if you choose to host your database on amazon web-services, you gonna have a bad time
	2. you can't easily test your app. If you want to have a test database, a development database and a production database, you can't easily change it.
	3. you can't easily change your database url. you need to dive into the code and find the corresponding line.
	4. because.
- so, what should I do ?
	* you should use an environment variable, it could be a file loaded when the app starts (`.env`) or a config file (`config.py`) that **won't** be commited.
	* when you deploy an app on [heroku](https://www.heroku.com/) for example, heroku gives you the URL of the database via through an environment variable.


### 1.3 - Fixing hard-coded information

Let's update our structure.

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
touch .env
pip install python-dotenv
pip freeze > requirements.txt
```

We install `python-dotenv` because flask needs it to automaticaly load `.env` files.

Speaking about `.env`, let's create it :

```bash
# .env
DATABASE_URL=sqlite:///db.sqlite
```

and update our application factory `__init__.py` :

```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)
    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')

    from .database import db
	db.init_app(app)

    from .api_v1 import api as api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

**Much** better :-)

## 2 - Adding models

Now that SQLAlchemy is imported, let's add our models (tables).

For this flask course, I would like to create a bootstrap application that you can re-use each time you start a new flask project. 99% (* number made up by me) your app will need users, login/signup etc...

Let's create a `models` folder

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
mkdir models
```

Thank's to python [multiple inheritance](https://en.wikipedia.org/wiki/Multiple_inheritance), we can declare a `Base` model that we will import everytime we need the same fields in a Model. Creating a `Base` model allows us to write [DRY code](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

Create a file for our `Base` model :

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
touch models/base.py
```

and declare it :

```python
# models/base.py

from ..database import db


class Base(db.Model):

    __abstract__ = True

    id = db.Column(db.Integer, primary_key=True)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    updated_at = db.Column(db.DateTime,
                    default=db.func.current_timestamp(),
                    onupdate=db.func.current_timestamp())
```

and now we create a file for our `User` model :

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
touch models/user.py
```
and we declare it :

```python
# models/user.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from .base import Base
from ..database import db


class User(Base):

    __tablename__ = 'users'

    username = db.Column(db.String, nullable=False, unique=True)
    email = db.Column(db.String, nullable=False, unique=True)
    encrypted_password = db.Column(db.String, nullable=False)
```

`User` model will inherit from `Base` (and `db.Model` via `Base`) so it will have `id, created_at, updated_at` fields.

`__tablename` is optional but I strongly recommend setting it because with weird class names it's quite hard to know the final table name.


## 3 - Generating the database

SQLAlchemy will generate the database and the tables based on our code. But we need a way to trigger this event.

You could choose to reset the database everytime your app restarts, but it's gonna lead to troubles.

We will rather use the command-cli provided by Flask. (and it's an excuse for me to show you how to use the cli).

Let's create a file called `cli.py` that will host all our commands.

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
touch cli.py
```

```python
# cli.py

import click
from flask.cli import with_appcontext
from .database import db


@click.command('reset-db')
@with_appcontext
def reset_db_command():
    """Clear existing data and create new tables."""
    # run it with : FLASK_APP=. flask reset-db
    # import every model here to be created
    from .models.user import User
    db.drop_all()
    db.create_all()
    click.echo('The database has been reset.')


def cli_init_app(app):
    app.cli.add_command(reset_db_command)
```

Here, we declare a `click.command` that will drop-then-create all the tables. That's why we need to import every model.

Now that we declared our command, we need to import it into our `application factory` aka `__init__.py` via `cli_init_app`.

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

We are now **ready** to test our brand new app.

## 4 - Testing

```bash
# assuming you're in flask_learning/my_app_v3 (venv)
FLASK_APP=. flask reset-db
```

If the command succeeds, a `db.sqlite` file should appear.

To make sure that our databse was correctly created, we can inspect it via a database browser. 

For SQLite, a great tool is [sqlite-browser](http://sqlitebrowser.org/).

![v3 sqlitebrowser example](/img/courses/dev/python/flask_part_3/v3_sqlitebrowser.png)


## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_3` to see the reference code. And use `reset.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to connect a database to your app. But our app is quite useless right now, isn't it ?.. 

Don't worry, if you understood everything, you're now ready to go to [part 4](/courses/dev/python/flask_part_4/) to see how to add a signup, login and roles to your users !
