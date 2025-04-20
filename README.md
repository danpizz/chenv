# chenv

**chenv** is a tool for managing groups of Bash environment variables. It simplifies handling complex configurations that go beyond the capabilities of traditional `.env` files, especially when working with dynamic values from secret managers like 1Password.

```
╭──────────────────────────────────╮╭──────────────────────────────────────────────────╮
│   env-example-1                  ││ env-example-2 ()                                 │
│ ▌ env-example-2                  ││ {                                                │
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

## Features

- Manage groups of environment variables as Bash functions.
- Interactively choose and apply environment variable groups using `fzf`.
- Supports multiple selections for applying multiple groups.
- Provides a way to inspect the active environment configuration.
- Works seamlessly with secret managers for dynamic values.

## Installation

1. Copy the `chenv.sh` script to a directory in your system's `PATH`.
2. Ensure `fzf` and `realpath` are installed on your system.

## Usage 

Defining Environment Groups
Environment groups are defined in a `.chenv` file in the current directory as Bash functions. For example:

```
env-example-1() {
    export TAG="a1"
    export DB_NAME=my_local_db
    export DB_HOST=
    export MY_SECRET=xxx
}

env-example-2() {
    export TAG="b"
    export DB_NAME=prod_db
    export DB_HOST=aws.com
    export DB_USER=$(op read op://vault/name/username)
    export DB_PASSWORD=$(op read op://vault/name/password)
}
```

### Commands

`chenv`

Run `chenv` to choose between the available environment groups. The groups are displayed in an interactive fzf interface, allowing you to select one or more groups to apply. The selected groups are applied in a new shell.

`chenv -s`

Use `chenv -s` to show the currently active environment configuration. By default, sensitive values (e.g., passwords) are obscured. Use the -v flag to display them in plain text:

`chenv -s -v`

###  Using `.chenv` without `chenv`

You can manually source the .chenv file and call the functions directly in your current shell:

```
$ . .chenv
$ env-example-1
$ echo $DB_NAME
my_local_db
```

## Example Workflow

1. Create a `.chenv` file in your project directory with your environment groups.
1. Run `chenv` to select and apply a group of environment variables.
1. Use `chenv -s` to inspect the active configuration.

## Notes

* **Safety**: A previous version of chenv allowed modifying the current shell's environment directly. This was removed to avoid accidental overwrites and ensure better traceability.
* **Customization**: You can define `NO_OPS` in your `.chenv` file to prevent the execution of commands other than `op` (used for the 1Password CLI, which is hardcoded) during the `chenv -s` command. If you require support for skipping additional CLI commands, please open an issue to request their inclusion.

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve chenv.

## Acknowledgments

Inspired by the need for better environment variable management in complex Bash workflows.
Thanks to the creators of fzf for their powerful fuzzy finder tool.




