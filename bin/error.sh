############################################################
## @file   error.sh
##
## @brief  proper error handling in shell scripts,
##         simply include via source /path/to/error.sh,
##         use alias die to exit with proper message
##
## @author Christian Otto
##
## @date   Fri May 24 12:00:04 CEST 2013
##
############################################################

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

error_handler() {
    echo 1>&2
    echo 1>&2 "Error in ${0} with '${1}' at line ${2}"
}
exit_handler() {
    echo 1>&2
    echo 1>&2 "$@"
    exit 1
}
trap 'error_handler "$*" $LINENO' ERR
alias die='exit_handler "Exit in ${0}:"'
