#!/usr/bin/env bash

set -euo pipefail

DEFAULT_CONFIG_FILE="$(realpath -q ./.chenv)"

# list the functions declared in the file provided as parameter
list_functions() {
    file="$1"
    bash --noprofile --norc -c "source $file; declare -F" | cut -w -f 3
}

# prints all the variables that the current shell exports except PATH
exported_vars() {
    export -p | cut -d ' ' -f 3 | cut -d = -f 1 | grep -v "^PATH$"
}

# list the exported variables whose names are declared somewhere in the file
# provided as parameter
list_exported_var_names() ( # we use "(" here so we are in a subshell
    file="$1"
    if [[ -z "$file" ]]; then
        return
    fi

    # unset all exported variables except PATH
    # shellcheck disable=SC2046
    unset $(exported_vars)

    # source the configuration file, define the no-ops and call all the functions
    # the no-ops are commands we want to ignore when executing the configuration
    # functions like for example "op" the 1Password CLI. 
    # the NO_OPS variable is a list of commands to ignore that can be defined in the
    # configuration file
    # shellcheck source=/dev/null
    source "$file"
    for f in op ${NO_OPS:=}; do
        eval "function $f { : ; }"
        echo "no op: $f"
    done
    for f in $(list_functions "$file"); do
        $f
    done

    # the exported variables are now those set by the functions
    exported_vars
)

chenv-show() {
    arg_verbose=${1:-}
    if [[ -z ${__chenv_config:=} ]]; then
        echo "chenv was not executed in this shell."
        return 1
    fi
    if [[ ! -f $__chenv_config ]]; then
        echo "the chenv config file \"${__chenv_config}\" is missing (deleted?)."
        return 1
    fi
    if [[ ${__chenv_config_sha:=} != $(sha512sum "$__chenv_config" | cut -d ' ' -f 1) ]]; then
        echo "The chenv config file \"${__chenv_config}\" was modified, the following info may not be accurate."
    fi

    echo "Configuration file: $__chenv_config"
    echo "Environment:"
    for var in $(list_exported_var_names "$__chenv_config"); do
        [[ -v "$var" ]] || continue
        if [[ $arg_verbose == "-v" ]]; then
            echo "- $var=${!var}"
        else
            echo "- $var=${!var}" | sed -r 's/(^.*PASSWORD=|^.*PASS=|^.*SECRET.*=)(.*)/\1***/'
        fi
    done
}

chenv() {
    file=$"$DEFAULT_CONFIG_FILE"

    if [[ ! -f "$file" ]]; then
        echo "No configuration file in current directory."
        exit 1
    fi

    if ! chosen_functions=$(list_functions "$DEFAULT_CONFIG_FILE" |
        fzf -m \
            --layout=reverse-list \
            --style=full \
            --height=10% \
            --min-height=10+ \
            --preview-window=60% \
            --preview "bash -c \"source $file; declare -f {}\""); then
        return 1
    fi

    file_sha="$(sha512sum "$file" | cut -d ' ' -f 1)"
    val="export __chenv_config=$file;export __chenv_config_sha=$file_sha;$chosen_functions"
    exec bash --rcfile <(echo "source ~/.bashrc; source $file; eval $val") -i
}

if [[ $# -eq 0 ]]; then
    chenv
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s | --show)
            shift
            chenv-show "$@"
            ;;
        *) break ;;
    esac
done
