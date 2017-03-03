#!/bin/bash
# testrun script
FILENAME=$(basename "$0")
BASEDIR=$(dirname "$0")
VERBOSE='false'

LOGFILE='/tmp/THX.log'

function log() {
  local tag=$1
  local message=$2
  local log_result
  local msg_result
  local show

  log_result="$(date '+%Y-%m-%d %H:%M:%S') ($tag) $FILENAME : $message"

  case $tag in
    E )
      msg_result+="Error :"
      show='true'
      ;;
    I )
      msg_result+="Info :"
      [[ $VERBOSE == 'true' ]] && show='true'
      ;;
    M )
      msg_result+="Message :"
      show='true'
      ;;
    * )
      msg_result+="Special :"
      [[ $VERBOSE == 'true' ]] && show='true'
      ;;
  esac

  msg_result+=" $message"

  [[ $show == 'true' ]] && echo $msg_result
  echo $log_result >> $LOGFILE
}

function getHostData() {


  # Get os name via uname ###
  HOST_OS="$(uname)"
  case $HOST_OS in
    Darwin)
      log 'I "HOST_OS=$HOST_OS : OSX detected."'
      ;;
    Linux)
      log I "HOST_OS=$HOST_OS : LINUX detected."
      log E "$(lsb_release -sd)"
      ;;
    FreeBSD|OpenBSD)
      log I "HOST_OS=$HOST_OS : BSD detected."
      ;;
    SunOS)
      log I "HOST_OS=$HOST_OS : SUNOS detected."
      ;;
    *)
      log I "Unrecognized operating system."
      ;;
  esac
}

echo "GETHOSTDATA ---------------"
 getHostData


# function screen() {
echo "DUMPDATA ---------------"
  echo "FILENAME=$FILENAME"
  echo "BASEDIR=$BASEDIR"

  echo
  echo


  echo  '$0 - File name : ' $0
  echo  '$1 - Arg 01 : ' $1
  echo  '$2 - Arg 02 : ' $2
  echo  '$@ - All args : ' $@
  echo  '$# - Args total : ' $#
  echo  '$! - : ' $!

# }
