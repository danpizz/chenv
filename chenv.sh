# shellcheck shell=bash
#
# chenv, chenv-show, chenv-unset, chenv-reload
#
# this file must be sourced

# shellcheck source=/dev/null
[[ -f "$CHENV_PROJECT_FILE" ]] && source "$CHENV_PROJECT_FILE"

# list the functions declared in the configuration file
__chenv_list_functions() {
    bash --noprofile --norc -c "source $CHENV_PROJECT_FILE; declare -F" | cut -w -f 3
}

# list the exported variables declared in the configuration file
__chenv_list_var_names() ( # we use "(" here so we are in a subshell
    [[ -f "$CHENV_PROJECT_FILE" ]] || return

    # private function that prints all exported variables except PATH
    # grep -v CHENV_PROJECT_FILE is to avoid unsetting the configuration file
    # in the case of people mistakenly using export on the CHENV_PROJECT_FILE variable.
    exported_vars() {
        export -p | cut -d ' ' -f 3 | cut -d = -f 1 | grep -v PATH | grep -v CHENV_PROJECT_FILE
    }

    # unset all exported variables except PATH
    # shellcheck disable=SC2046
    unset $(exported_vars)

    # create a phony op command to avoid calling 1Password
    op() {
       :
    }

    # source the configuration file and call all the functions
    source "$CHENV_PROJECT_FILE"
    for f in $(__chenv_list_functions); do
        $f
    done

    # the exported variables are now those set by the functions
    exported_vars
)

chenv-show() {
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
}

chenv() {
    if ! [[ -f "$CHENV_PROJECT_FILE" ]]; then
        echo "CHENV_PROJECT_FILE is not set"
        return 1
    fi
    eval "$(__chenv_list_functions | fzf --preview "bash -c \"source $CHENV_PROJECT_FILE; declare -f {}\"")"
}

chenv-reload() {
    source "${BASH_SOURCE[0]}"
    [[ -f "$CHENV_PROJECT_FILE" ]] && source "$CHENV_PROJECT_FILE"
}
