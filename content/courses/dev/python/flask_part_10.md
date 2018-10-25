---
title: "Flask - Part 10"
description: "Example of a (complete) Flask app + Docker"
date: 2018-10-22
githubIssueID: 0
tags: ["flask"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---


## Introduction

This `version_10` is the last part of this course. There won't be a lot of explanations here. 

I simply added some features that I will list below. This app is here to be examined and for you to learn on your own.

This page may change as I add more features (like alembic for DB migrations for example).

## Features

* UUID primary keys
    * I wanted to change the type of the primary keys of the different tables. Choosing UUID over auto-increment integers has a lot of benefits and not a lot of drawbacks.
    * [article](https://www.clever-cloud.com/blog/engineering/2015/05/20/why-auto-increment-is-a-terrible-idea/)
* Username regex validation
    * quick example on how to parse a username (remember, you need to validate data both in the front-end AND in the back-end). This regex is here to avoid users to choose hard-to-parse username so their username can be use as a parameter in a route.
    * you should rather use the UUID of the user instead of its username (if you allow your users to change their username then the bookmarked routes won't work etc etc...)
* Role management
* a front-end route
    * to show you how to serve a front-end (like an angularjs app)
* an upload route
    * because

## Docker

Quick explanation about how to dockerize your app.

0. Make sure you have `gunicorn` in your `requirements.txt`.

1. Create a file named `Dockerfile` and add those lines : (yes, that's a lot of comment)

```
# this dockerfile inherit from https://github.com/docker-library/python/blob/38dcdb4320c8668416205e044ee50489c059da18/3.7/stretch/slim/Dockerfile
FROM python:3-slim

# we add a user that will run our app so it's not run by root
RUN groupadd -g 999 flaskou && useradd -r -u 999 -g flaskou flaskou

WORKDIR /home/flaskou

# we copy our app inside the container, the folder will be created
# we chown the folder to the user flaskou
COPY --chown=flaskou:flaskou . ./

# we install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# we switch user to the one we created earlier
USER flaskou

# we run some useful commands like creating the database and creating the first admin
RUN flask reset-db && \
	flask create-admin "root" "root@mail.com" "toor"

# we share this folder with the host
VOLUME /home/flaskou

# finally we run our app
CMD [ "gunicorn", "-b :5000", "wsgi:app" ]

# we expose the port 5000 so the host can access it
EXPOSE 5000
```

2. Build the image :

```bash
# " . " represents the current folder, where Dockerfile is
docker build -t flaskou .
```

(if you encounter errors like `Temporary failure in name resolution [Errno -3]`, please check out [this article](https://gist.github.com/gmolveau/6fa0ddb4546ec5bd073d0037370be31e)).

3. Run your app

```bash
docker run -p 5000:5000 flaskou
```

## Conclusion

I **hope** that you found this big flask course cool and helpful !

Feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below if you have any question about Flask or web-development in general.