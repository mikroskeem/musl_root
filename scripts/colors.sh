__ttput="x"
__tput () {
    if [ "${__ttput}" = "x" ]; then
        if [ -z "${TERM}" ]; then
            __ttput="true"
        else
            __ttput="$(command -v tput || printf '%s' 'true')"
        fi
    fi

    "${__ttput}" "${@}"
}

_cred="$(__tput setaf 1)"
_cgreen="$(__tput setaf 2)"
_cyellow="$(__tput setaf 3)"
_cblue="$(__tput setaf 4)"
_cbold="$(__tput bold)"
_cnormal="$(__tput sgr0)"

status () {
    echo "${_cbold}>>> ${_cgreen}Status:${_cnormal} ${*}"
}

inform () {
    echo "${_cbold}>>> ${_cnormal}Info:${_cnormal} ${*}"
}

note () {
    echo "${_cbold}>>> ${_cblue}Note:${_cnormal} ${*}"
}

warning () {
    echo "${_cbold}>>> ${_cyellow}Warning:${_cnormal} ${*}"
}

error () {
    echo "${_cbold}>>> ${_cred}Error:${_cnormal} ${*}"
}
