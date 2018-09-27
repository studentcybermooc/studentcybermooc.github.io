---
title: "Flask - Part 1"
description: "Introduction to Flask"
date: 2018-09-21
githubIssueID: 0
tags: ["flask", "python"]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

## Table of contents

- [Introduction](#introduction)
  * [Concepts](#concepts)
- [Setting up the project](#setting-up-the-project)
- [Discovering Flask](#discovering-flask)
  * [Coding our first app](#coding-our-first-app)
  * [Running our first app](#running-our-first-app)
  * [Testing our app](#testing-our-app)
    + [Postman testing](#postman-testing)
    + [HTTPie testing](#httpie-testing)
- [Conclusion](#conclusion)
  * [Version 1](#version-1)

---

## Introduction

Welcome to the first part of this massive Flask REST api course.

First of all, I'll assume that you have followed my previous course : [setting up your python environment](/courses/dev/python/set_up_python_env/).  
If you haven't, please do so :-)

You should have python3, pip and git installed.

### Concepts

- flask

---

## Setting up the project

For this course we will create multiple folders :

```bash
mkdir flask_learning
cd flask_learning
git clone https://github.com/gmolveau/flask_cybermooc
mkdir my_app_v1
```

<pre>
flask_learning
├── flask_cybermooc
│	├── version_1	# reference code
│	├── [...]
│   └── version_XXX	
└── my_app_v1		# your folder
</pre>

You now have one folder for you (`my_app_v1`), and another one (`flask_cybermooc`) with every version I'll use in this course.

---

## Discovering Flask

Flask is a python web micro-framework. What can Flask help you with ? Quickly building a web-app.

### Coding our first app

Let's try a dead-simple flask app.

```bash
$ cd my_app
$ virtualenv venv -p python3 #create the venv
$ source venv/bin/activate # enter the venv
$ pip install flask 
$ pip freeze > requirements.txt # save the list of dependencies into requirements.txt
(venv) $ touch app.py
```

- Let's code our first app, in app.py - copy this code :
	```
	from flask import Flask
	app = Flask(__name__)

	@app.route('/')
	def hello_world():
	    return 'Hello, World!'
	```

Nothing fancy in this, we just created a `route` accessible at '/' and told flask to return 'Hello, World!' if someone requests this route.

---

### Running our first app

Let's launch this app :

```bash
(venv) $ FLASK_ENV=development FLASK_APP=app.py flask run --host=0.0.0.0 --port=5000
```

![v1 flask run example](/img/courses/dev/python/flask/v1_flask_run.png)

So what's going on here ?

We told flask:
- to run our app in development mode | `FLASK_ENV=development`
	- development mode enables auto-reload if you modify your source code, you also have access to the flask debugger
- that our app was located in `app.py` | `FLASK_APP=app.py`
- to bind the server to every network interface | `--host=0.0.0.0`
- and to use the port number `5000` (it's the default port but this is to show how to change the port if needed) | `--port=5000`

---

### Testing our app

To try and test your first route, many tools are available. 

I personnaly use these two :

- [postman](https://www.getpostman.com/apps) : GUI tool, awesome app, lots of options and ways to use it
	- you can create "collections" of requests to test your app
- [httpie](https://httpie.org/#installation) : command-line tool, kinda more user-friendly curl
	- install it with : `pip install httpie --user`

---

#### Postman testing

- when you first launch postman, you don't need to create an account, just click on the very-well-hidden link "skip signing in and take me straight to the app" at the bottom.
- then close the inner window that just appeared.

![v1 postman example](/img/courses/dev/python/flask/v1_postman.png)

Our request worked and we received "Hello, World!" so all good.

---

#### HTTPie testing

![v1 httpie example](/img/courses/dev/python/flask/v1_httpie.png)

Everything is working great :-)

---

## Conclusion

We just saw how to create a route, how to launch our server and how to test this route with postman and httpie. 

### Version 1

This was the `version 1` of our app. 

To check if your code is correct, please go to `flask_learning/flask_cybermooc/version_1` to see the original code.

If you understood everything, you're now ready to go to [part 2](/courses/dev/python/flask_part_2/) ! 