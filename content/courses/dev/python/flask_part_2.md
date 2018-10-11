---
title: "Flask - Part 2"
description: "Architecture of a Flask app"
date: 2018-09-22
githubIssueID: 0
tags: ["flask", "python", "blueprint"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

### Introduction

This `version_2` will explain how to structure your project to easily integrate your models, templates, ORM ...

For this `version_2`, we will code the same app as `version_1`, no big deal.

## 1 - How to structure our app

To organize our routes, let's start again from scratch and create a new folder :

```bash
# assuming you're in flask_learning
mkdir my_app_v2
cd my_app_v2
```

initialize our venv :

```bash
# assuming you're in flask_learning/my_app_v2
virtualenv venv -p python3
source venv/bin/activate
# (venv)
pip install -r requirements.txt # install from the requirements.txt file
```

and now lay down our achitecture :

```bash
# assuming you're in flask_learning/my_app_v2 (venv)
touch __init__.py
mkdir api_v1
touch api_v1/__init__.py api_v1/hello.py
```

With this architecture, we can easily update our api without breaking backward-compatibility.


## 2 - Creating our app

### 2.1 - Application factory

An `application factory` is the function `create_app` that returns our app. This function is located in `__init__.py`


```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)

    from .api_v1 import api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

- An application factory is mandatory to launch our app via a WSGI server (gunicorn, nginx...)
- line 9 : we use blueprints to organize our app into components.


### 2.2 - Our first API

Let's create declate our `api_v1` in `api_v1/__init__.py`.

```python
# api_v1/__init__.py

from flask import Blueprint

api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Import any endpoints here to make them available
from . import hello
```

- line 5 : this blueprint has a prefix `/api/v1`. Every route **inside** this blueprint will be prefixed by `/api/v1`.
- line 8 : we are importing from the current folder `.` the file `hello.py` that will contain some endpoints.


### 2.3 - Our first route

Let's code our fiirst route in `api_v1/hello.py`:

```python
# api_v1/hello.py

from . import api_v1_blueprint

@api_v1_blueprint.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'
```

As we saw earlier, this route belong to `api_v1_blueprint` so it will be prefixed by `/api/v1`. This route will be accessible at `/api/v1/` (notice the last slash /).


### 2.4 - Testing our app

Let's launch this app :

```bash
# assuming you're in flask_learning/my_app_v2 (venv)
FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```

- `HTTPie` :

![v2 httpie example](/img/courses/dev/python/flask_part_2/v2_httpie.png)

- `Postman` :

![v2 postman example](/img/courses/dev/python/flask_part_2/v2_postman.png)

Working great :-)

## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_2` to see the reference code. And use `reset.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to structure your app to easily extend it in the (near) future.

You're now ready to go to [part 3](/courses/dev/python/flask_part_3/) to learn how to connect your app with a database.