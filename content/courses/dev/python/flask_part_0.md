---
title: "Flask - Part 0 - Intro"
description: "Introduction to Flask"
date: 2018-09-20
githubIssueID: 0
tags: ["flask", "python"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---

## Welcome

Welcome to the _flask_ course !

This (quite big) flask course will teach you how to build a REST API using `flask micro-framework`.

Before we continue, I'll assume that, you have followed my previous course : [setting up your python environment](/courses/dev/python/set_up_python_env/) and that you know how to code in python3 (object oriented too).

You should have `python3`, `pip`, `virtualenv` and `git` installed.

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
```

You now have the `flask_cybermooc` folder with every version that we will see during this course.

<pre>
flask_learning
│
└── flask_cybermooc
    └── every version 
</pre>

## 2 - Other things

In every sub-folders of `flask_learning/flask_cybermooc`, you will find a `run.sh` file.

This file is here to help you launch the reference app so you can quickly correct your code if it's not working. This script has 4 functions : `clean, setup, run, test`.

If you want to launch the code, you simply need to call :

```bash
# assuming you're in flask_learning/flask_cybermooc/version_XXX
sh run.sh clean
sh run.sh setup
sh run.sh run
sh run.sh test
```

## 3 - Every parts

Here's the list of every part of this course :

- [part 1 - Super Basic Flask app](/courses/dev/python/flask_part_1/)
- [part 2 - Architecture of a Flask app](/courses/dev/python/flask_part_2/)
- [part 3 - Connecting Flask with a database](/courses/dev/python/flask_part_3/)
- [part 4 - Adding users and login/signup routes](/courses/dev/python/flask_part_4/)
- [part 5 - User authentication with Json Web Token](/courses/dev/python/flask_part_5/)
- [part 6 - Roles management](/courses/dev/python/flask_part_6/)
- [part 7 - Restricting access with role verification](/courses/dev/python/flask_part_7/)
- [part 8 - Implementing JWT whitelisting](/courses/dev/python/flask_part_8/)
- [part 9 - Revoking JWT](/courses/dev/python/flask_part_9/)
- [part 10 - Example of a (complete) Flask app + Docker](/courses/dev/python/flask_part_10/)

## Conclusion

Now that everything is set-up, let's begin with our first part of this course and build a dead-simple flask app.

[Click here to go to part 1](/courses/dev/python/flask_part_1/)