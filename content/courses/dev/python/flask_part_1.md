---
title: "Flask - Part 1"
description: "Introduction to Flask"
date: 2018-09-21
githubIssueID: 0
tags: ["flask", "python"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

## Introduction

**WELCOME** ! 

Welcome to the first part of my _flask_ course.

This (quite big) flask course will teach you how to build a REST api using flask micro-framework.

Before we continue, I'll assume that, you have followed my previous course : [setting up your python environment](/courses/dev/python/set_up_python_env/) and that you know how to code in python3 (object oriented too).

You should have python3, pip and git installed.

## 1 - Creating our environment

In order to easily manage every parti of this course, let's create a dedicated folder.

```bash
mkdir flask_learning
cd flask_learning
```

`flask_learning` will be your main folder.

Let's now grab a copy of every part of this course.

```bash
# assuming you are in flask_learning
git clone https://github.com/gmolveau/flask_cybermooc
mkdir my_app_v1
cd my_app_v1
```

You now have one folder for you (`my_app_v1`), and another one (`flask_cybermooc`) with every version I'll use in this course.

<pre>
flask_learning
│
├── flask_cybermooc
│   └── every version 
└── my_app_v1           (*)   # your folder
</pre>


## 2 - Discovering Flask

Flask is a python web micro-framework. What can Flask help you with ? Quickly building a web-app.

### 2.1 - Coding our first app

Let's try a dead-simple flask app.

```bash
# assuming you are in flask_learning/my_app_v1
virtualenv venv -p python3 #create the venv
source venv/bin/activate # enter the venv
pip install flask 
pip freeze > requirements.txt # save the list of dependencies into requirements.txt
# (venv)
touch app.py
```

Let's code our first app, in app.py - copy this code :

```python
# app.py

from flask import Flask
app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'Hello, World!'
```

Nothing fancy in this, we just created a `route` accessible at '/' and told flask to return 'Hello, World!' if someone requests this route.


### 2.2 - Running our first app

Let's launch this app :

```bash
# assuming you are in flask_learning/my_app_v1
# (venv)
FLASK_ENV=development FLASK_APP=app.py flask run --host=0.0.0.0 --port=5000
```

![v1 flask run example](/img/courses/dev/python/flask_part_1/v1_flask_run.png)

So what's going on here ?

We told flask:
- to run our app in development mode &rarr; `FLASK_ENV=development`
	- development mode enables auto-reload if you modify your source code, you also have access to the flask debugger
- that our app was located in `app.py` &rarr; `FLASK_APP=app.py`
- to bind the server to every network interface &rarr; `--host=0.0.0.0`
- and to use the port number `5000` (it's the default port but this is to show how to change the port if needed) &rarr; `--port=5000`


### 2.3 - Testing our app

To try and test your first route, many tools are available. 

I personnaly use these two :

- [postman](https://www.getpostman.com/apps) : GUI tool, awesome app, lots of options and ways to use it
	- you can create "collections" of requests to test your app
- [httpie](https://httpie.org/#installation) : command-line tool, kinda more user-friendly curl
	- install it with : `pip install httpie --user`

#### 2.3.1 - Testing with postman

- when you first launch postman, you don't need to create an account, just click on the very-well-hidden link "skip signing in and take me straight to the app" at the bottom.
- then close the inner window that just appeared.

![v1 postman example](/img/courses/dev/python/flask_part_1/v1_postman.png)

Our request worked and we received "Hello, World!" so all good.

#### 2.3.2 - Testing with httpie

![v1 httpie example](/img/courses/dev/python/flask_part_1/v1_httpie.png)

Everything is working great :-)

## Conclusion

We just saw how to create a route, how to launch our server and how to test this route with postman and httpie. 

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_1` to see the reference code. And use `reset.sh` to launch it.

If you understood everything, you're now ready to go to [part 2](/courses/dev/python/flask_part_2/) where you will learn how to connect a database to your app.
