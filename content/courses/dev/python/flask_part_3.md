---
title: "Flask - Part 3"
description: "Flask + SQLalchemy"
date: 2018-09-23
githubIssueID: 0
tags: ["flask", "python", "sqlalchemy", "orm"]
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

This `version_3` will show you how to connect your app with a database via sqlalchemy and how to create models.

### Concepts

- flask
- ORM
- sqlalchemy

---

## Setting up

To begin we will start from our previous version_2 app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_2 my_app_v3
cd my_app_v3
mkdir models
```

<pre>
flask_learning
│
├── flask_cybermooc
│	├── version_1	
│	├── version_2
│	├── version_3	# reference code
│   └── version_XXX	
├── my_app_v1
├── my_app_v2
└── my_app_v3 (*)	# your folder
</pre>

your `my_app_v3` folder should look like this :

<pre>
my_app_v3
│
├── .editorconfig
├── requirements.txt
├── __init__.py 		# contains our app
└── api_v1 				
	├── __init__.py
    └── hello.py
</pre>

Let's create our venv.

```bash
# assuming you're in flask_learning/my_app_v3
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install flask
(venv) $ pip freeze > requirements.txt
```

All set up ? let's begin.

---

## SQLAlchemy

SQLAlchemy is a python ORM. If you don't know what an ORM is, it basically is an object representation of your database. A python object (eg. a 'User') represents the table 'user' in your database. It allows you to use methods like 'get', 'query', 'first' instead of writing pure SQL.

### Installing sqlalchemy

In our venv, with flask already installed, let's install `flask_sqlalchemy` which contains sqlalchemy + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ pip install flask-sqlalchemy
(venv) $ pip freeze > requirements.txt
```

---

### Adding sqlalchemy to our app

Now that sqlalchemy is installed, we need to tell our app to use sqlachemy when it starts.

It’s a good idea to keep the SQLAlchemy object instance in a separate file, to avoid [circular imports](https://en.wikipedia.org/wiki/Circular_dependency).

To do so, let's create the db file :

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ touch database.py
```

and add this code :

```python
# database.py
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()
```

Then in your application_factory `__init__.py`, let's modify our code like this :

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

So, a couple of new things going on here.

- line 4 : we import the database variable from `database.py`
- line 8 : we define the connection to the database
	- here we specify that our database is a `sqlite` file with the name 'db'
- line 10 : we add the database to our app

[_nota bene_](https://fr.wikipedia.org/wiki/Nota_bene): you should never [hard-code](https://forum.wordreference.com/threads/hard-coded.105554/?hl=fr) the URL of the database in your code, this is a **bad** practice.

- why ? (not safe, not practical, bad pattern)
	1. if you commit your code on a public repository, everyone can see it. Here it's a simple sqlite, but if you choose to host your database on amazon web-services, you gonna have a bad time
	2. you can't easily test your app. If you want to have a test database, a development database and a production database, you can't easily change it.
	3. you can't easily change your database url. you need to dive into the code and find the corresponding line.
	4. because.
- so, what should I do ?
	* you should use an environment variable, it could be a file loaded when the app starts (`.env`) or a config file (`config.py`) that **won't** be commited.
	* when you deploy an app on [heroku](https://www.heroku.com/), heroku gives you the URL of the database via an environment variable

Let's change our code then :

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ touch .env
(venv) $ pip install python-dotenv
(venv) $ pip freeze > requirements.txt
```

- why do we have to install `python-dotenv`?
	- because flask needs it when you call `flask run` to automaticaly load `.env` files

in `.env` add those lines : 

```bash
DATABASE_URL=sqlite:///db.sqlite
```

and change the code in `__init__.py` (line 8-9) :

```python
# __init__.py

from flask import Flask
from .database import db

def create_app():
    app = Flask(__name__)
    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')

	db.init_app(app)

    from .api_v1 import api as api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

Your folder should look like this:

<pre>
my_app_v3
│
├── .editorconfig
├── .env 				# **never** commit this file
├── requirements.txt
├── __init__.py 		# contains our application factory
├── database.py 		# contains our database (duh.)
└── api_v1 				
	├── __init__.py
    └── hello.py
</pre>

There. **Much** better :-)

---

## Adding models

Now that our database is connected, we need to add some real models (tables).

Most of the time, your app will need users. So let's add that.

Create `models` folder, then create a file `users.py` and add this code :

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ mkdir models
(venv) $ touch models/user.py
```

```python
# models/user.py
# http://docs.sqlalchemy.org/en/latest/orm/extensions/declarative/basic_use.html

from ..database import db

class User(db.Model):

	__tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String, nullable=False, unique=True)
    email = db.Column(db.String, nullable=False, unique=True)
    encrypted_password = db.Column(db.String, nullable=False)
```

Pretty basic user, with an integer as primary key, a username, an email and an encrypted_password.

We will also create a `module` to easily import all the models.

```bash
# assuming you're in flask_learning/my_app_v3
(venv) $ touch models/__init__.py
```

```python
# models/__init__.py

# import all the models here
from .user import User
```

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
