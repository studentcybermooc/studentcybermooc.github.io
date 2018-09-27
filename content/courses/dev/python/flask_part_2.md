---
title: "Flask - Part 2"
description: "Architecture of a Flask app"
date: 2018-09-22
githubIssueID: 0
tags: ["flask", "python", "blueprint"]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

## Table of contents

- [Introduction](#introduction)
  * [Concepts](#concepts)
- [Architecture](#architecture)
- [Our app](#our-app)
  * [Launcher](#application-factory)
  * [API](#api)
  * [Route](#route)
  * [Testing](#testing)
- [Conclusion](#conclusion)

---

## Introduction

This `version_2` will explain how to structure your project to easily integrate your models, templates, ORM ...

For this version_2, we will code the same app as version_1, no big deal.

### Concepts

- flask
- blueprint

---

## Architecture

To organize our routes, let's start again from scratch and create a new folder :

```bash
# assuming you're in flask_learning
$ mkdir my_app_v2
$ cd my_app_v2
```

<pre>
flask_learning
│
├── flask_cybermooc
│	├── version_1	
│	├── version_2	# reference code
│   └── version_XXX	
├── my_app_v1		# first version of your app
└── my_app_v2 (*)	# your folder
</pre>

and now lay down our achitecture :

```bash
# assuming you're in flask_learning/my_app_v2
$ touch __init__.py
$ mkdir api_v1
$ touch api_v1/__init__.py api_v1/hello.py
```

<pre>
my_app_v2
│
├── .editorconfig
├── requirements.txt
├── __init__.py 		# contains our app
└── api_v1 				# our routes
    └── __init__.py

</pre>

This architecture is great if we want to change our api, because if our api becomes public, it should not change all the time, so we can easily create an `api_v2` folder.

---

## Our app

### Application factory

This file, `__init__.py` containing the `create_app` function is called the application factory.

- In `__init__.py`, let's code :

	```python
	# __init__.py

	from flask import Flask

	def create_app():
	    app = Flask(__name__)

	    from .api_v1 import api as api_v1_blueprint
	    app.register_blueprint(api_v1_blueprint)

	    return app
	```

So, a couple of new things going on here.

- Why did we create a `create_app` function instead of just declaring our app like we did in version_1 ?
	* If we want our app tobe launched via a WSGI server (like gunicorn, nginx or other), we need to have a function returning our app.
- What is a `blueprint` (line 9) ?
	- a blueprint is made to organize our app into components.

---

### API

Let's now code this blueprint, in `api_v1/__init__.py`:
	```python
	# api_v1/__init__.py

	from flask import Blueprint

	api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

	# Import any endpoints here to make them available
	from . import hello
	```

Again, what's going on here ?

- line 5 : we are declaring our blueprint `api_v1_blueprint`. This blueprint has a prefix `/api/v1`. It means that every route **inside** this blueprint will be prefixed by `/api/v1`.
- line 8 : we are importing from `.` (so from the current folder) the file `hello.py` that will contain a simple route

---

### Route

- Let's now code this route, in `api_v1/hello.py`:

	```python
	# api_v1/hello.py

	from . import api

	@api.route('/', methods=['GET'])
	def hello_world():
	    return 'Hello, World!'
	```

Nothing new here it's the same route as in version_1 :-)

This route will be accessible at : `/api/v1/` (notice the last slash /).

---

Let's launch this app :

```bash
# assuming you're in flask_learning/my_app_v2
(venv) $ FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

### Testing

![v2 httpie example](/img/courses/dev/python/flask/v2_httpie.png)

![v2 postman example](/img/courses/dev/python/flask/v2_postman.png)

---

## Conclusion

This part explained how to structure our app so we can easily extend it in the (near) future.

To check if your code is correct, please go to `flask_learning/flask_cybermooc/version_2` to see the reference code. And use `reset.sh` or `reset.bat` to launch it.

If you understood everything, you're now ready to go to [part 3](/courses/dev/python/flask_part_3/) to learn how to connect your app with a database.