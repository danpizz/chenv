# chenv

A tool for managing bash environment variables.

chenv helps handle configurations that are too complex for regular .env files,
particularly when dealing with dynamic values from slow secret managers like
1Password.

When changing environments, chenv shows you the proposed changes before applying them. This preview feature helps prevent configuration mistakes.

Here's a practical example showing different database configurations. We have a configuration to connect to a local database:

```
DB_NAME=my_local_db
DB_HOST=
```

and another to connect to the staging or prod one:

```
DB_NAME=prod_db
DB_HOST=aws.com
DB_USER=$(op read op://vault/name/username)
DB_PASSWORD=$(op read op://vault/name/password)
```

now you can do this in various ways but with chenv you can preview what will happen:


```
                                ╭──────────────────────────────╮
                                │ local ()                     │
                                │ {                            │
                                │     DB_NAME=my_local_db;     │
                                │     DB_HOST=                 │
                                │ }                            │
                                │                              │
                                │                              │
                                │                              │
  prod                          │                              │
▌ local                         │                              │
  2/2 ──────────────────────────│                              │
>                               ╰──────────────────────────────╯
```

```
                                ╭──────────────────────────────╮
                                │ prod ()                      │
                                │ {                            │
                                │     DB_NAME=prod_db;         │
                                │     DB_HOST=aws.com;         │
                                │     USER=$(op read op://v    │
                                │     PASSWORD=$(op read op    │
                                │ }                            │
                                │                              │
▌ prod                          │                              │
  local                         │                              │
  2/2 ──────────────────────────│                              │
>                               ╰──────────────────────────────╯
```

## Available commands

* `chenv`: choose between the available sets
* `chenv-show`: show the active environment (passwords hidden unless `-v`)
* `chenv-unste`: unset the active environment

You can also directly call the function defined in the configuration.

## Installation

Copy the `chenv.sh` script somewhere and source it in your bash initialization.

## Configuration

Define a script containing functions that export your variables and set the
`CHENV_PROJECT_FILE` variable to point at it. Important: do not export the
`CHENV_PROJECT_FILE` variable.