#!/usr/bin/env sh
# shellcheck disable=SC2155
# Symlink script

set -o errexit

# ------------------------------------------------------------------ Globals -
readonly AUTHOR="Thibault HULAUX"
readonly DATE="2024-06-30"
readonly VERSION="0.1.1"

readonly ARGS="${*}"
readonly PROGDIR="$(cd "$(dirname "$(readlink -f "${0}")")" && pwd)"
readonly PROGNAME="$(basename "$(readlink -f "${0}")")"

# ---------------------------------------------------------------- Functions -
eexit() { printf "%s\n" "${PROGNAME}: Exit: ${*}" 1>&2; exit 1; }
info() { printf "%s\n" "${PROGNAME}: ${*}"; }

helptext() {
  cat >&2 << EOF
==============================================================================
$PROGNAME($VERSION) - $DATE $AUTHOR
------------------------------------------------------------------------------
Install / uninstall dotfiles symlinks.

Source: ${SRC}
Destination: ${DEST}

Usage: ${PROGNAME} [-h|--help] [i|install|u|uninstall]

Commands:
  i, install                          Install links
  u, uninstall                        Uninstall links

Options:
  -h, --help                          Display this screen

EOF
}

usage() {
  cat >&2 << EOF
Usage: ${PROGNAME} [-h|--help] [install|uninstall]
EOF
}

dotfiles_install() {
  local src="${1}"
  local dest="${2}"
  local files=$(find "${src}" -mindepth 1)
  for file in ${files}; do
    local target="${dest}$(echo ${file} | sed s!.*${src}!!)"
    if [ -e "${target}" ]; then
      # skip existing
      info "${target} already exists"
    elif [ -d "${file}" ]; then
      # create directory
      info "$(mkdir -v "${target}")"
    elif [ -f "${file}" ]; then
      # create link
      info "$(ln -sv "${file}" "${target}")"
    fi
  done
  echo 'for file in $(find ~/.config/bash -mindepth 1); do source ${file}; done' >> ~/.bashrc
}

dotfiles_uninstall() {
  local src="${1}"
  local dest="${2}"
  local files=$(find "${src}" -mindepth 1 | sort -r)
  for file in ${files}; do
    local target="${dest}$(echo ${file} | sed s!.*${src}!!)"
    if [ -e "${target}" ]; then
      if [ -f "${file}" ] && [ -h "${target}" ]; then
        # remove file
        info "$(rm -v "${target}")"
      elif [ -d "${file}" ]; then
        # remove directory
        info "$(rmdir -v --ignore-fail-on-non-empty "${target}")"
      fi
    fi
  done
  sed -i 's!for file in $(find ~/.config/bash -mindepth 1); do source ${file}; done!!' ~/.bashrc
}

# --------------------------------------------------------------------- Main -
main() {
  local src="${PROGDIR}/src/unix"
  local dest="${HOME}"
  [ -d "${src}" ] || eexit "${src} doesn't exist"
  [ -d "${dest}" ] || eexit "${dest} doesn't exist"
  case "${1}" in
    "i" | "install" )
    dotfiles_install "${src}" "${dest}"
    ;;
    "u" | "uninstall" )
    dotfiles_uninstall "${src}" "${dest}"
    ;;
    "-h" | "--help" )
    helptext
    ;;
    * )
    usage
    ;;
  esac
}

# ------------------------------------------------------------------ Runtime -
main "${ARGS}"
exit 0
