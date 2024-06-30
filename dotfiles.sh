#!/usr/bin/env sh
# shellcheck disable=SC2155
# Symlink script

set -o errexit

# ------------------------------------------------------------------ Globals -
readonly AUTHOR="Thibault HULAUX"
readonly DATE="2023-01-07"
readonly VERSION="0.1.0"

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
    # skip existing
    if [ -e "${target}" ]; then
      info "${target} already exists."
    # create directory
    elif [ -d "${file}" ]; then
      info "$(mkdir -v "${target}")"
    # create link
    elif [ -f "${file}" ]; then
      info "$(ln -sv "${file}" "${target}")"
    fi
  done
}

dotfiles_remove() {
  local src="${1}"
  local dest="${2}"
  # remove links
  local files=$(find "${src}" -mindepth 1 -type f)
  for file in ${files}; do
    local target="${dest}$(echo ${file} | sed s!.*${src}!!)"
    if [ -e "${target}" ] && [ -h "${target}" ]; then
      info "$(rm -v "${target}")"
    fi
  done
  # remove directories
  local folders=$(find "${src}" -mindepth 1 -type d | sort -r)
  for folder in ${folders}; do
    local target="${dest}$(echo ${folder} | sed s!.*${src}!!)"
    if [ -e "${target}" ] && [ -d "${target}" ]; then
      info "$(rmdir -v --ignore-fail-on-non-empty "${target}")"
    fi
  done
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
    dotfiles_remove  "${src}" "${dest}"
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
