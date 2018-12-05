#!/usr/bin/env sh

echo_blue() {
  printf "\033[34m$1\033[0m"
  echo
}

echo_green() {
  printf "\033[32m$1\033[0m"
  echo
}

echo_yellow() {
  printf "\033[33m$1\033[0m"
  echo
}

echo_red() {
  printf "\033[31m$1\033[0m"
  echo
}
