---
title: "Flask - Part 9"
description: "Revoking tokens"
date: 2018-09-29
githubIssueID: 0
tags: ["flask", "jwt"]
authors: {
    gmolveau: "/authors/gmolveau/"
}
draft: true
---


## Introduction

This `version_9` will teach you how to implement user revokation of its tokens.


### Setting up

To begin we will start from our previous `version_8` app. If you don't have it anymore, no worries, simply copy the reference code.

```bash
# assuming you're in flask_learning
cp flask_cybermooc/version_8 my_app_v9
cd my_app_v9
```

and we create our venv.

```bash
# assuming you're in flask_learning/my_app_v9
$ virtualenv venv -p python3
$ source venv/bin/activate
(venv) $ pip install -r requirements.txt
```

All set up ? let's begin.

## 1 - Listing the tokens

The user should have a route to get all its tokens so it can revoke some/all of them.

So let's create `api_v1/token.py` to host our routes.

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
touch api_v1/token.py 
```

And add our listing route :

```python
# api_v1/token.py

from flask import jsonify
from . import api_v1_blueprint
from .decorators import login_required
from ..database import db
from ..schemas.token import tokens_schema


@api_v1_blueprint.route('/tokens', methods=['GET'])
@login_required
def route_list_tokens(current_user):
    json_tokens = tokens_schema.dump(current_user.tokens).data
    return jsonify(tokens=json_tokens)
```

And we add this new file to our module `api_v1/__init__.py`.

```python
# api_v1/__init__.py

from flask import Blueprint

api_v1_blueprint = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Import any endpoints here to make them available
from . import hello
from . import user
from . import token
```

### 1.1 - Testing

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
FLASK_APP=. flask reset-db
FLASK_APP=. flask create-admin 'root' 'root@mail.com' 'toor'
FLASK_ENV=development FLASK_APP=. flask run --host=0.0.0.0 --port=5000
```
Let's login, get our token back and try to request `GET /api/v1/tokens`.

![v9_bug_serializable](/img/courses/dev/python/flask_part_9/v9_bug_serializable.png)

Uh oh... Flask is telling us that our Token model object is not `JSON serializable`.

So how does an Object become `JSON serializable` ? 

&rarr; This Object should have a method that returns a dict.

So we can either create a function or a method that does that, or we can use `schemas` !

## 2 - Marshmallow

Marshmallow is a python serialize/deserializer. It can convert complex datatypes, such as objects, to and from native Python datatypes (eg. convert our Token python Object to JSON and vice-versa).

And what is a schema ?

A schema can be used to validate, serialize and deserialize data. It is a way to tell marshmallow which fields to take, which to exclude.

### 2.1 - Installing marshamallow

In our venv, let's install `flask-marshmallow` which contains marshmallow + a wrapper for flask.

And we don't forget to update our `requirements.txt`.

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
pip install flask-marshmallow marshmallow-sqlalchemy
pip freeze > requirements.txt
```


### 2.2 - Adding sqlalchemy to our app

Now that marshamallow is installed, we need to tell our app to use marshmallow when it starts.

It’s a good idea to keep the Marshmallow object instance in a separate file

Let's create the marshmallow file :

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
touch marshmallow.py
```

and add this code :

```python
# marshmallow.py

from flask_marshmallow import Marshmallow

ma = Marshmallow()
```

Then in the application_factory `__init__.py`, let's import our fresh marshmallow instance:

```python
# __init__.py

from flask import Flask

def create_app():
    app = Flask(__name__)

    from os import environ as env
    app.config['SQLALCHEMY_DATABASE_URI'] = env.get('DATABASE_URL')

    from .database import db
    db.init_app(app)

    from .bcrypt import bc
    bc.init_app(app)

    from .cli import cli_init_app
    cli_init_app(app)

    from .marshmallow import ma
    ma.init_app(app)

    from .api_v1 import api_v1_blueprint
    app.register_blueprint(api_v1_blueprint)

    return app
```

All good, let's continue and create declare our schemas.

### 2.3 - Creating our marshmallow schemas

Let's create a folder dedicated to our schemas (schemas of our models).

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
mkdir schemas
```

and a file for our Token object.

```bash
# assuming you're in flask_learning/my_app_v9 (venv)
touch schemas/token.py
```

and we declare our schema :

```python
# schemas/token.py
# https://marshmallow.readthedocs.io/en/3.0/quickstart.html
# https://marshmallow.readthedocs.io/en/3.0/extending.html
# https://marshmallow.readthedocs.io/en/latest/nesting.html

from marshmallow import fields
from ..marshmallow import ma
from ..models import Token


class TokenSchema(ma.ModelSchema):

    class Meta:
        model = Token


token_schema = TokenSchema()
tokens_schema = TokenSchema(many=True)
```

This schema simply import the Token model to get all the fields and export 2 schemas.

## 3 - Fixing our route

Now that our schema is declared, let's fix our listing tokens route.

```python
# api_v1/token.py

from flask import (
    jsonify, request
)
from . import api_v1_blueprint
from .decorators import valid_token_required
from ..schemas.token import tokens_schema


@api_v1_blueprint.route('/tokens', methods=['GET'])
@valid_token_required
def route_list_tokens(current_user):
    json_tokens = tokens_schema.dump(current_user.tokens).data
    return jsonify(tokens=json_tokens)
```

### 3.1 - Testing

![v9_schemas_dump](/img/courses/dev/python/flask_part_9/v9_schemas_dump.png)

Well, it's working great :) 

Now what if we want to exclude the hash ? Because the user does not need it.

&rarr; We can update our schema and tell marshmallow to exclude the `hash` field.

```python
# schemas/token.py
# https://marshmallow.readthedocs.io/en/3.0/quickstart.html
# https://marshmallow.readthedocs.io/en/3.0/extending.html
# https://marshmallow.readthedocs.io/en/latest/nesting.html

from ..marshmallow import ma
from ..models import Token


class TokenSchema(ma.ModelSchema):

    class Meta:
        model = Token
        exclude = ['hash']


token_schema = TokenSchema()
tokens_schema = TokenSchema(many=True)
```

Now the `hash` won't be serialized.

![v9_schemas_dump_exclude](/img/courses/dev/python/flask_part_9/v9_schemas_dump_exclude.png)

## 4 - Revoking a token

Now that our user can list all its tokens, it would be great to be able to revoke a token. Let's add a route in `api_v1/token.py` then.

```python
# api_v1/token.py

from flask import jsonify
from . import api_v1_blueprint
from .decorators import login_required
from ..database import db
from ..schemas.token import tokens_schema

[...]

@api_v1_blueprint.route('/tokens/<int:token_id>', methods=['DELETE'])
@login_required
def route_delete_token(current_user, token_id):
    for user_token in current_user.tokens:
        if user_token.id == token_id:
            db.session.delete(user_token)
            db.session.commit()
            return jsonify(msg="the token has been deleted"), 200
    return jsonify(err="404 token not found"), 404
```

### 4.1 - Testing

![v9_revoke_token](/img/courses/dev/python/flask_part_9/v9_revoke_token.png)

All right cool :-) A user can now list its tokens and revoke them !

## Conclusion

If you're stuck or don't understand something, feel free to drop [me an email / dm on twitter](/authors/gmolveau/) / a comment below. You can also take a look at `flask_learning/flask_cybermooc/version_9` to see the reference code. And use `reset.sh` to launch it.

Otherwise, **congratulations** ! You just learned how to implement token whitelisting.

You're now ready to go to [part 10](/courses/dev/python/flask_part_10/) to see a full example of a [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete).