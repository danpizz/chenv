# chenv

A tool for managing groups of bash environment variables.

`chenv` helps handle configurations that are too complex for regular `.env` files,
particularly when dealing with dynamic values from slow secret managers like
1Password.

When changing environments, chenv shows you the proposed changes before applying
them via `fzf`.

```
╭──────────────────────────────────╮╭──────────────────────────────────────────────────╮
│   env-example-3                  ││ env-example-4 ()                                 │
│ ▌ env-example-4                  ││ {                                                │
│                                  ││     export DB_NAME=prod_db;                      │
│                                  ││     export DB_HOST=aws.com;                      │
│                                  ││     export USER=$(op read op://vault/name/userna │
│                                  ││     export PASSWORD=$(op read op://vault/name/pa │
│                                  ││ }                                                │
│                                  ││                                                  │
│                                  ││                                                  │
╰──────────────────────────────────╯│                                                  │
╭──────────────────────────────────╮│                                                  │
│ >                        2/2 (0) ││                                                  │
╰──────────────────────────────────╯╰──────────────────────────────────────────────────╯
```

Groups of environment variables are defined in a `.chenv` file in the current
directory as regular bash functions:

```
env-example-4() {
    export __CHENV_FUNC=4
    export DB_NAME=prod_db
    export DB_HOST=aws.com
    export USER=$(op read op://vault/name/username)
    export PASSWORD=$(op read op://vault/name/password)
}
```

This file is sourced to the current shell and the functions are called by `chenv`.

`chenv-show` will precisely show the current active configuration by looking at the
variables of the current shell that are defined in some of the functions.

## Available commands

* `chenv`: choose between the available environment sets
* `chenv-show`: show the active environment (passwords hidden unless `-v`)
* `chenv-unset`: unset the active environment
* `chenv-load`: load the configuration file in the current directory.
* `chenv-export`: exports a function for the chosen set.

You can also directly call the function defined in the configuration.

## Installation

Copy the `chenv.sh` script somewhere and source it. You may want to do this in your bash initialization.
