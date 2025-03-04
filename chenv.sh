# shellcheck shell=bash
#
# chenv, chenv-show, chenv-unset, chenv-reload
#
# this file must be sourced

__chenv_get_functions_file_path(){
    if [[ -n $__chenv_current_file ]]; then
        echo "$__chenv_current_file"
    elif [[ -f .chenv ]]; then
        echo .chenv
    elif [[ -f "$CHENV_FILE" ]]; then
        echo "$CHENV_FILE"
    fi
}

# list the functions declared in the configuration file
__chenv_list_functions() {
    local file=$(__chenv_get_functions_file_path)
    bash --noprofile --norc -c "source $file; declare -F" | cut -w -f 3
}

# function that prints all exported variables except PATH and CHENV_FILE.
# grep -v CHENV_FILE is used to avoid unsetting the configuration file
# in the case of people mistakenly using export on the CHENV_FILE variable.
__chenv_exported_vars() {
    local file=$(__chenv_get_functions_file_path)
    export -p | cut -d ' ' -f 3 | cut -d = -f 1 | grep -v "^PATH$" | grep -v "^CHENV_FILE$"
}

# list the exported variables declared in the configuration file
__chenv_list_var_names() ( # we use "(" here so we are in a subshell
    local file=$(__chenv_get_functions_file_path)
    if  [[ -z "$file" ]]; then
        return
    fi

    # unset all exported variables except PATH
    # shellcheck disable=SC2046
    unset $(__chenv_exported_vars)

    # create a phony op command to avoid calling 1Password
    op() {
       :
    }

    # source the configuration file and call all the functions
    source "$file"
    for f in $(__chenv_list_functions); do
        $f
    done

    # the exported variables are now those set by the functions
    __chenv_exported_vars
)

chenv-show() {
    local file=$(__chenv_get_functions_file_path)
    if [[ -z "$file" ]]; then
        echo "No configuration file."
        return 1
    fi
    echo "Configuration file: $file"
    echo "Environment:"
    for var in $(__chenv_list_var_names); do
        [[ -v "$var" ]] || continue
        if [[ "$1" = "-v" ]]; then
            echo "$var=${!var}"
        else
            echo "$var=${!var}" | sed -r 's/(^.*PASSWORD=|^.*PASS=)(.*)/\1***/'
        fi
    done
}

chenv-unset() {
    # shellcheck disable=SC2046
    unset $(__chenv_list_var_names)
    unset __chenv_current_file
}

chenv() {
    local file=$(__chenv_get_functions_file_path)
    if [[ -z "$file" ]]; then
        echo "No configuration file."
        return 1
    fi
    f=$(__chenv_list_functions | \
        fzf -m \
            --layout=reverse-list \
            --style=full \
            --height=10% \
            --min-height=10+ \
            --preview-window=60% \
            --preview "bash -c \"source $file; declare -f {}\"")
    if [[ $? != 0 ]]; then
        return 1
    fi
    . "$file"
    eval "$f"
    __chenv_current_file="$(realpath $file)"
}

chenv-load() {
    source "${BASH_SOURCE[0]}"
    source $(__chenv_get_functions_file_path)
}

chenv-export() (
    local file=$(__chenv_get_functions_file_path)
    if [[ -z "$1" ]]; then
        f=$(__chenv_list_functions | fzf --preview "bash -c \"source $file; declare -f {}\"")
    else
        f=$1
    fi

    # unset all exported variables except PATH
    # shellcheck disable=SC2046
    unset $(__chenv_exported_vars)

    # create a phony op command to avoid calling 1Password
    op() {
       :
    }

    # source the configuration file and call the requested functions
    source "$file"
    "$f"

    export -p | grep -v PATH | grep -v CHENV_FILE
)
