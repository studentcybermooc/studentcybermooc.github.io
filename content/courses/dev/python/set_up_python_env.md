---
title: "Setting up your python environment"
description: "Learn how to set up a clean python environment"
date: 2018-09-19
githubIssueID: 15
tags: ["python", "environment"]
draft: false
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)

---

## Table of contents

- [Introduction](#introduction)
  * [Concepts](#concepts)
- [Requirements](#requirements)
  * [Installing Python3](#installing-python3)
  * [Using pip](#using-pip)
  * [Using virtualenv](#using-virtualenv)
- [Let's do this](#let-s-do-this)
  * [Setting up a venv](#setting-up-a-venv)
  * [Experimenting with pip and venv](#experimenting-with-pip-and-venv)
  * [Listing your dependencies](#listing-your-dependencies)
  * [.editorconfig](#editorconfig)
  * [Versioning](#versioning)
- [Choosing your IDE](#choosing-your-ide)
- [Conclusion](#conclusion)
  * [Summary](#summary)
  * [Going further](#going-further)

---

## Introduction

This course will teach you how to set-up a clean python environment for all your projects

### Concepts

- python3
- virtual environment
- dependency management

---

## Requirements

### Installing Python3

Make sure you've got `python3` and `pip3` installed on your system.
To check if you have it installed try running :

```bash
python3 -v
```

You should see some lines with `/usr/lib/python3.XXX`

```bash
import 'atexit' # <class '_frozen_importlib.BuiltinImporter'>
# /usr/lib/python3.XXX/__pycache__/rlcompleter.cpython-36.pyc matches /usr/lib/python3.XXX/rlcompleter.py
# code object from '/usr/lib/python3.6/__pycache__/rlcompleter.cpython-36.pyc'
import 'rlcompleter' # <_frozen_importlib_external.SourceFileLoader object at 0x7f053e35d5c0>
>>> 
```

Same thing for `pip` with :

```bash
pip --version
```

You should see `(python 3.XXX)` at the end of the line. If the command `pip` does not exist, try with `pip3 --version`.

```bash
pip 18.0 from /home/gmolveau/.local/lib/python3.XXX/site-packages/pip (python 3.6)
```

If you don't have python3 installed:

- for windows, [download this executable](https://www.python.org/downloads/) and make sure to check "Add python to PATH ".

- for mac, run :
	```bash
	brew install python3
	```
	(if you don't have brew installed, [go there](https://brew.sh/index_fr))

- for linux, run :
	```bash
	sudo apt-get isntall python3-pip python3-dev
	```

---

### Using pip

Pip is the dependency manager for python (like npm for nodejs, cargo for rust, composer for php [...]). It allows you to download framework and libraries. When you install a dependency with `pip install XXX --user`, it installs it only for the current user.

```bash
$ pip3 install gimgurpython --user
Collecting gimgurpython
  Using cached https://files.pythonhosted.org/packages/7a/e9/7bf364691f3a16de4b161765282c8cde4ac9924542bddea7d0c2a8aa0351/gimgurpython-0.0.4-py2.py3-none-any.whl
Requirement already satisfied: requests in /usr/lib/python3/dist-packages (from gimgurpython) (2.18.4)
Installing collected packages: gimgurpython
Successfully installed gimgurpython-0.0.4
```

To see where a certain dependency is installed, try `pip show ...` and look at the Location line.
For example : `Location: /home/gmolveau/.local/lib/python3.6/site-packages`.

```bash
$ pip3 show gimgurpython          
Name: gimgurpython
Version: 0.0.4
Summary: A fork of Official Imgur python library with OAuth2 and samples, modified as it seems not maintained anymore
Home-page: https://github.com/gmolveau/imgurpython
Author: Imgur Inc. (+ gmolveau)
Author-email: api@imgur.com
License: MIT
Location: /home/gmolveau/.local/lib/python3.XXX/site-packages
Requires: requests
Required-by: 
```

But sometimes for a project, you will have to download a specific version of a dependency, and if this dependency is already installed for another project in another version, you gonna have a bad time.

That's why we will use `virtualenv`.

---

### Using virtualenv

Virtualenv is a tool to create isolated Python environments. (if you want to learn more about it [go there](https://virtualenv.pypa.io/en/stable/)).

This tool will allow us to create a virtual environment for each project. It means no more dependency correlation. This also means that you will be able to share your project with every dependencies easily via a file called `requirements.txt` (more on this later).

To install virtualenv, simply run :

```bash
pip install virtualenv
```

You can now create virtual environments, called a `venv`.

---

## Let's do this

### Setting up a venv

Now that we have everything we need :

- let's create a project :

	- linux/osx

		```bash
		mkdir /tmp/project
		cd /tmp/project
		```

	- windows

		```bash
		mkdir %TMP%\project
		cd %TMP%\project
		```

- create a venv

	```bash
	virtualenv venv -p python3
	```

	This command tells virtualenv to create a virtual environment, to create a folder `venv` where the virtual environment will be located, and to use python3.

- now that the venv is created, we need to enter into this venv
	
	- linux/osx
		```bash
		source venv/bin/activate
		```

	- windows
		```bash
		venv\Scripts\activate
		```

	you should now see `(venv)` at the beginning of your shell

	![virtualenv example](/img/courses/dev/python/set_up_python_env/virtualenv.png)

---

### Experimenting with pip and venv

Let's now install a library

```bash
(venv) pip install flask
```

now if you look at where flask was installed with `pip show flask` you'll see that its directly into our venv. more specifically in `venv/lib/python3.X/site-packages`. So our venv is working well :-)

![venv flask example](/img/courses/dev/python/set_up_python_env/venv_flask.png)

Now let's try to run : 

```bash
(venv) flask --version
```

It should return `Flask 1.x.x [...]`.

Now open another terminal and try to run :

```bash
flask --version
```

You should have a `command not found` in return. Flask is available **only** inside your venv. No more pollution of your entire machine now :-)

If you wan't to quit your venv, simply run :

```bash
(venv) deactivate
```

---

### Listing your dependencies

If you want to share your project, and list all the dependencies necessary to build it, pip is going to help you.

In your venv, run :

```bash
(venv) pip freeze
```

You should see all the dependencies and versions.

![pip freeze example](/img/courses/dev/python/set_up_python_env/pip_freeze.png)

Now if you want to export this list, simply run

```bash
(venv) pip freeze > requirements.txt
```

You now have a practical way of sharing your dependencies :-)

Remember, you should **never** commit your `venv`. Only commit your `requirements.txt`. More about git_and_stuff in a moment.

---

### .editorconfig

This file, `.editorconfig` was made to tell your code-editor some presets about your code.
For example in sublime text, if you write python, you'll often encounter bugs due to the use of 'tab' instead of 'spaces'. This file is here to fix this.

- .editorconfig
	```
	# .editorconfig
	# http://editorconfig.org
	root = true

	[*]
	charset = utf-8
	insert_final_newline = true
	trim_trailing_whitespace = true

	[*.py]
	indent_size = 4
	indent_style = space

	[*.md]
	trim_trailing_whitespace = false
	```

	This configuration is pretty explicit. For example, it tells your code-editor that for python files, 'space' should be used as indentation, and that a tabulation is equal to 4 spaces.


You can [find](http://lmgtfy.com/?q=.editorconfig+springboot) examples of `.editorconfig` files for many kinds of project.

---

### Versioning

First here's an example of a `.gitignore` file for a python project :

- .gitignore (yes, it's huge)
	```
	venv/
	# Byte-compiled / optimized / DLL files
	__pycache__/
	.pytest_cache/
	*.py[cod]
	*$py.class

	# C extensions
	*.so

	# Distribution / packaging
	.Python
	env/
	build/
	develop-eggs/
	dist/
	downloads/
	eggs/
	.eggs/
	lib/
	lib64/
	parts/
	sdist/
	var/
	*.egg-info/
	.installed.cfg
	*.egg
	.cache/

	# PyInstaller
	#  Usually these files are written by a python script from a template
	#  before PyInstaller builds the exe, so as to inject date/other infos into it.
	*.manifest
	*.spec

	# Installer logs
	pip-log.txt
	pip-delete-this-directory.txt

	# Unit test / coverage reports
	htmlcov/
	.tox/
	.coverage
	.coverage.*
	.cache
	nosetests.xml
	coverage.xml
	*,cover
	.hypothesis/

	# Translations
	*.mo
	*.pot

	# Django stuff:
	*.log
	local_settings.py

	# Flask stuff:
	instance/
	.webassets-cache

	# Scrapy stuff:
	.scrapy

	# Sphinx documentation
	docs/_build/

	# PyBuilder
	target/

	# IPython Notebook
	.ipynb_checkpoints

	# pyenv
	.python-version

	# celery beat schedule file
	celerybeat-schedule

	# dotenv
	.env

	# virtualenv
	venv/
	ENV/
	env/
	.flaskenv

	# Spyder project settings
	.spyderproject

	# Rope project settings
	.ropeproject

	# Mac OSX
	**/.DS_Store


	# JetBrains products
	.idea/

	# Misc
	_mailinglist
	```


This .gitignore will prevent you of commiting some useless/dangerous files (temporary, compiled, credentials [...]).

Also, a course will be soon available about git workflows to work effectively in team. (but if you [can't wait](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)).

---

## Choosing your IDE

There's no good/bad/worst/attrocious IDE; choose the one you're the most effective with and that won't go into your way when you wan't to work.

BUT if you don't have an IDE yet or if you want to try a new one, I'm currently using two products :

- [sublime text](https://www.sublimetext.com/) + lots of additional packages (via package control)
- [pycharm](https://www.jetbrains.com/pycharm/)

Sublime Text is not really (natively) an IDE but with the help of additional packages, it can be.

Pycharm **is** an IDE and helps you in a **lot** of ways. You'll have to learn some shortcuts and stuff, but for professional python programming, [imho](https://www.dictionary.com/browse/imho) it's the best one.

---

## Conclusion

OKkkkkay so now you should know how to easily set-up your python environment :-)

We've seen how pip and virtualenv works and how to make a clean place when working on a new project.

---

### Summary

[TL;DR](https://en.wikipedia.org/wiki/TL;DR) ?

So a quick workflow for every new project is :

```bash
mkdir project; cd project
touch .editorconfig (then paste the config)
touch .gitignore (then paste the config)
touch README.md

virtualenv venv -p python3
source venv/bin/activate (enter the venv)
pip install XXX
pip freeze > requirements.txt
pip install YYZZ
pip freeze > requirements.txt

git init
git add .gitignore .editorconfig requirements.txt README.md
git commit -m "init project"

deactivate (quit the venv)
```

---

### Going further

- If you don't like managing your venv, requirements.txt etc... :

	a tool was created **just for you** then and it's called [pipenv](https://pipenv.readthedocs.io/en/latest/). Here's a [french explanation](http://sametmax.com/pipenv-solution-moderne-pour-remplacer-pip-et-virtualenv/) of this tool.

- If you want to learn more about how python really works :

	- [watch this conference by James POWELL](https://www.youtube.com/watch?v=7lmCu8wz8ro)
	- [watch this other conference by Nina Zakharenko](https://www.youtube.com/watch?v=F6u5rhUQ6dU)
	- [and this one by Raymond HETTINGER](https://www.youtube.com/watch?v=wf-BqAjZb8M)
	- [RTFM#1](https://docs.python.org/3/tutorial/datastructures.html)


- and more globaly : [read this book by Kevlin HENNEY](http://shop.oreilly.com/product/9780596809492.do)

- If you want to apply your newly acquired knowledge on something useful, please follow our course on how to build an API with Flask.