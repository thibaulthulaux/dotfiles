#!/bin/bash
  FILENAME=$(basename "$0")
  BASEDIR=$(dirname "$0")
  VERSION="0.0.1"
# ==============================================================================
#                                                                        CONFIG
  DEBUG=1
  THX_ROOT="/tmp"
  THX_LOGFILE=""
  THX_PATH=""
  THX_FUNCTIONS=("THX.test")

# ==============================================================================
#                                                                USER FUNCTIONS
function THX.tmux() {

  # abort if we're already inside a TMUX session
  [ "$TMUX" == "" ] || exit 0
  # startup a "default" session if non currently exists
  # tmux has-session -t _default || tmux new-session -s _default -d

  # present menu for user to choose which workspace to open
  PS3="Please choose your session: "
  options=($(tmux list-sessions -F "#S" 2>/dev/null) "New Session" "zsh")
  echo "Available sessions"
  echo "------------------"
  echo " "
  select opt in "${options[@]}"
  do
  	case $opt in
  		"New Session")
  			read -p "Enter new session name: " SESSION_NAME
  			tmux new -s "$SESSION_NAME"
  			break
  			;;
  		"zsh")
  			zsh --login
  			break;;
  		*)
  			tmux attach-session -t $opt
  			break
  			;;
  	esac
  done


}

function THX.rsync() {

  SRC="/home/thibault/dev"
  DEST="/Users/thibault/"
  USER="thibault"
  HOST="192.168.131.1"

  if [[ -d "$SRC" ]]; then
    echo "LOG > Pushing $SRC to $HOST:$DEST"
    CMD="rsync -e ssh -avzn --delete-after $SRC $USER@$HOST:$DEST"
    echo "LOG > Issuing : $CMD"
    #rsync -e ssh -avzn --delete-after $SRC $USER@$HOST:$DEST
    rsync -e ssh -avz --delete-after $SRC $USER@$HOST:$DEST
    echo "LOG > Done."
    #bash -x $CMD
  else
    echo "ERR >  $SRC not found."
    exit
  fi

  # rsync -e ssh -avz --delete-after /home/source user@ip_du_serveur:/dossier/destination/
  # rsync -e ssh -avz --delete-after /home/source user@ip_du_serveur:/dossier/destination/
}

function THX.test() {
  echo "Hello world !"
}

function THX.dumpAll() {
  set -o posix
  set
}

# ==============================================================================
#                                                                          CORE
function printInfo() {
  echo "FILENAME=$FILENAME"
  echo "BASEDIR=$BASEDIR"
  echo "VERSION=$VERSION"
  echo "DEBUG=$DEBUG"
}

function printVersion() {
  echo "$FILENAME $VERSION"
}

function log() {
  if [[ $DEBUG="1" ]]; then
    echo "[THX] $(date '+%Y-%m-%d %H:%M:%S') > $1";
  fi
}

function getHostData() {

  log "$(lsb_release -sd)"
  # Get os name via uname ###
  HOST_OS="$(uname)"
  case $HOST_OS in
    Darwin)
      log "OSX detected."
      ;;
    Linux)
      log "LINUX detected."
      ;;
    FreeBSD|OpenBSD)
      log "BSD detected."
      ;;
    SunOS)
      log "SUNOS detected."
      ;;
    *)
      log "Unrecognized operating system."
      ;;
  esac
}

function askConfirmation() {
  echo $1
  read -p "Do you want to continue ? [y/n]" -n 1 -r
  echo
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    log "$USER confirmed. ($REPLY)"
    return 0
  fi
  log "$USER denied. ($REPLY)"
  return 1
}

function askChoice() {
  echo $1
  i = 1
  for choice in $2; do
    echo "$i : $choice"
    i++
  done
  read -p "Please select [0/$i]" -n 1 -r

  return 0
}

function isInstalled() {
  if [ $(type -P $1) ]; then
    log "$1 installed in $(type -P $1)"
    return 0
  fi
  log "$1 not installed."
  return 1
}

function checkInstall() {
  if isInstalled $1; then
    log "$1 already installed, skipping installation."
    return 0
  else
    if askConfirmation "You're going to install $1."; then
        #if [[ sudo apt-get install $1 ]]; then
          log "(FAKE)Installation of $1 finished."
        #fi
        return 0
    else
      log "$USER aborted installation of $1."
    fi
    log "Installation of $1 failed."
    return 1
  fi
}
#------------------------------------------------------------------------- tmux
function tmuxCreateFile() {
  #statements
  return 0
}

function tmuxInit() {
  #statements
  if checkInstall "tmux"; then
    if tmuxCreateFile; then
      alias tmuxTHX="echo mescouilles"
      log "tmux setup finished."
    fi
  fi
}
#-------------------------------------------------------------------------- vim
function vimCreateFile() {
  #statements
  return 0
}

function vimInit() {
  #statements
  if checkInstall "vim"; then
    if vimCreateFile; then
      alias vimTHX="echo mabite"
      log "vim setup finished."
    fi
  fi
}



function backupFile() {
  log ""
  if [[ -f $1 ]]; then
    log "Moving $1 to "
}


#---------------------------------------------------------------------- aliases
function aliasesCreateFile() {() {

  # Shadowing aliases
  #alias ls="ls --color=auto"
  #alias ls="ls -G"
  #alias grep="grep --color=auto"

  # Listing aliases
  function l() { ls; }
  function la() { l -a; }
  function ll() { l -l; }
  function lla() { l -la; }

  # Navigation aliases
  function ..() { cd ..; }
  function ...() { cd ../..; }
  function ....() { cd ../../..; }
  function ~() { cd ~; }
}

function aliasesInit() {
  #statements
  if aliasesCreateFile; then

}
#----------------------------------------------------------------------- export
function exportUserFunctions() {
  #statements
  export -f $THX_FUNCTIONS
  log "User Functions exported."
}

function exportPATH() {
  #statements
  log "Specific PATH exported."
}
#-------------------------------------------------------------------------- run
function start() {
  #statements
  tmuxInit
  vimInit
  setAliases
  exportUserFunctions
  exportPATH
}

# ==============================================================================
#                                                                    MAIN LOGIC
case $1 in
  start)
    echo "Starting THX"
    start
    exit
    ;;
  stop)
    echo "stop-WorkInProgress"
    exit
    ;;
  info)
    printInfo
    exit
    ;;
  help)
    echo "help-WorkInProgress"
    exit
    ;;
  version)
    printVersion
    exit
    ;;
  *)
    echo "Apprends a utiliser tes script connard."
    exit
    ;;
esac
