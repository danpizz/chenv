# Subshella

**Bash environment group management with interactive selection and secret manager support.**

```
╭──────────────────────────────────╮╭──────────────────────────────────────────────────────╮
│   backend-dev                    ││ backend-tests ()                                     │
│ ▌ backend-tests                  ││ {                                                    │
│                                  ││     export DB_NAME=prod_db;                          │
│                                  ││     export DB_HOST=db-test.example.com;              │
│                                  ││     export USER=$(op read op://vault/tests-db/userna │
│                                  ││     export PASSWORD=$(op read op://vault/tests-db/pa │
│                                  ││ }                                                    │
│                                  ││                                                      │
│                                  ││                                                      │
╰──────────────────────────────────╯│                                                      │
╭──────────────────────────────────╮│                                                      │
│ >                        2/2 (0) ││                                                      │
╰──────────────────────────────────╯╰──────────────────────────────────────────────────────╯
```

Subshella (`ssa`) helps you manage groups of Bash environment variables with an interactive menu, making it quick to activate different configurations — especially when working with dynamic secrets from tools like 1Password CLI (`op`).

**No lock-in**: Your `.ssa` file is just Bash — use it with or without Subshella.

## Features

* Interactive [fzf](https://github.com/junegunn/fzf)-powered menu for selecting and activating environment groups

* Plain Bash function definitions — no special syntax

* Supports dynamic values from secret managers (e.g., 1Password CLI)

* Multiple group selection

* Inspect current environment safely (with secrets obscured)

* Manual sourcing always available

## Installation

### Prerequisites

- `fzf` (for interactive menu)
- `realpath` (for path resolution)
- Bash 4.0+ (for associative arrays)

### Install steps

1. Download `ssa.sh` to a directory in your `PATH`:
   ```
   curl https://raw.githubusercontent.com/danpizz/subshella/refs/heads/main/ssa.sh > /usr/local/bin/ssa.sh
   ```
1. Make it executable: 
   ```
   chmod +x /usr/local/bin/ssa.sh
   ```
1. Ensure `fzf` and `realpath` are installed on your system.

## Usage 

### Defining Environment Groups

Environment groups are defined in a `.ssa` file in the current directory as Bash functions. For example:

```
group-dev() {
    export TAG="a1"
    export DB_NAME=my_local_db
    export DB_HOST=
    export MY_SECRET=abc
}

group-prod() {
    export TAG="b"
    export DB_NAME=prod_db
    export DB_HOST=aws.com
    export DB_USER=$(op read op://vault/name/username)
    export DB_PASSWORD=$(op read op://vault/name/password)
}
```

### Commands

* `ssa`

   Launches an interactive fzf menu to select and apply environment groups in a new shell.

* `ssa -s`

    Shows the currently active environment configuration (secrets obscured).

* `ssa -s -v`

    Shows the current environment with all values revealed.


###  Manual Mode

You can always source .ssa and use the functions directly:

```
$ . .ssa
$ group-dev
$ echo $DB_NAME
my_local_db
```

### Example Workflow

1. Create a `.ssa` file in your project directory with your environment groups.
1. Run `ssa` to select and apply a group of environment variables, spawning a new shell.
1. Use `ssa -s` to inspect the active configuration.
1. Press Ctrl+D to exit the shell and clean up all variables.

## Security & Customization

* By default, `ssa -s` hides sensitive values (like passwords).
* To prevent execution of commands other than `op` (the 1Password cli) during inspection, define `NO_OPS` in your `.ssa` file.
* Need support for more CLI command skipping? [Open an issue!]

### Tip: Shell Level Indicator

If you use the [Starship prompt](https://starship.rs/), enable its [shlvl](https://starship.rs/config/#shlvl) module to show your current shell level. This makes it easy to see when you’re in a subshell launched by ssa.

Add this to your `~/.config/starship.toml`:

```
[shlvl]
disabled = false
threshold = 1
```

Now your prompt will show a shell level indicator whenever you’re in a subshell.

Great for keeping track of when `ssa` has started a new shell.

## License

This project is licensed under the MIT License.

## Contributing

Contributions and suggestions are welcome — open an issue or submit a pull request!

## Acknowledgments

Thanks to the creators of fzf and the open-source Bash community for inspiration.
