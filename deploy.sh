#!/usr/bin/env bash

set -e

# fn colors
echo_blue() {
  printf "\033[34m$1\033[0m\n"
}

echo_green() {
  printf "\033[32m$1\033[0m\n"
}

echo_yellow() {
  printf "\033[33m$1\033[0m\n"
}

echo_red() {
  printf "\033[31m$1\033[0m\n"
}
# --------------------

# Parse yml
# Based on https://github.com/jasperes/bash-yaml
yaml_parse() {
    local yaml_file=$1
    local prefix=$2
    local s
    local w
    local fs

    s='[[:space:]]*'
    w='[a-zA-Z0-9_.-]*'
    fs="$(echo @|tr @ '\034')"

    (
        sed -e '/- [^\“]'"[^\']"'.*: /s|\([ ]*\)- \([[:space:]]*\)|\1-\'$'\n''  \1\2|g' |

        sed -ne '/^--/s|--||g; s|\"|\\\"|g; s/[[:space:]]*$//g;' \
            -e "/#.*[\"\']/!s| #.*||g; /^#/s|#.*||g;" \
            -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
            -e "s|^\($s\)\($w\)${s}[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" |

        awk -F"$fs" '{
            indent = length($1)/2;
            if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
                }
            }' |

        sed -e 's/_=/+=/g' |

        awk 'BEGIN {
                FS="=";
                OFS="="
            }
            /(-|\.).*=/ {
                gsub("-|\\.", "_", $1)
            }
            { print }'
    ) < "$yaml_file"
}

yaml_create_variables() {
    local yaml_file="$1"
    eval "$(yaml_parse "$yaml_file")"
}
# --------------------

# Garbage collections
gc_releases() {
  MAX=${1:-10}

  echo
  echo_yellow "Garbage Collection in releases"

  # Check releases path exists in the APP
  if [[ ! -d "releases" ]]; then
      echo_red "Releases path not found! in '$(pwd)'"
      exit 1
  fi

  echo
  # Loop in the releases order by time
  count=0
  for f in $(ls -t releases/)
  do
    if [[ ${count} -gt ${MAX} ]]; then
      echo "DELETED $f"
      rm -rf "releases/$f"
    fi
    count=$((count+1))
  done
  echo
  echo_green "Finished Garbage Collection"
  echo
}
# --------------------

# Setup initial
init() {
  DIR=$(pwd)
  FILE_STAGE=".deploy/stage-$1.yml"

  echo
  echo_blue 'SETUP DEPLOY REMOTE---------------------------'
  echo

  # Validate APP path exists
  if [[ ! -d "$DIR/.deploy" ]]; then
      echo_red "APP not configured!"
      exit 1
  fi

  if [[ -f "$FILE_STAGE" ]]; then
    echo_yellow "Setup stage $FILE_STAGE"
    yaml_create_variables "$FILE_STAGE"
    cmd="mkdir -p $deploy_remote_path && cd $deploy_remote_path"
    cmd="$cmd && mkdir -p releases && mkdir -p shared && mkdir -p current"
    if [[ "$deploy_publish_git_url" ]]; then
      cmd="$cmd && rm -rf repo && git clone --depth 1 $deploy_publish_git_url repo"
    else
      cmd="$cmd && mkdir -p repo/.deploy"
    fi
    echo_yellow "Exec remote: $cmd"
    ssh -t "$deploy_remote_user@$deploy_remote_host" "$cmd"
    echo_green "Success full setup remote"
  else
    echo_red "Config file '$FILE_STAGE' not found!"
    exit 1
  fi

  echo
  echo_blue 'FINISHED SETUP DEPLOY REMOTE-----------------'
  echo
}
# --------------------

publish() {
  DIR=$(pwd)
  APP_STAGE=$1
  FILE_STAGE=".deploy/stage-$APP_STAGE.yml"

  echo
  echo_blue "PUBLISH '$APP_STAGE' ---------------------------"
  echo

  if [[ ! -f "$FILE_STAGE" ]]; then
    echo_red "Config file not found in the '$DIR/.deploy/'"
    exit 1
  fi

  yaml_create_variables "$FILE_STAGE"

  remote="$deploy_remote_user@$deploy_remote_host"
  remote_path="$deploy_remote_path"
  if [[ "$deploy_publish_git_url" ]]; then
    branch=${deploy_publish_git_branch:-master}
    cmd="cd $remote_path/repo && git fetch --depth 1 origin master && git reset --hard origin/$branch"
    echo $cmd
    ssh -t "$remote" "$cmd"
  elif [[ "$deploy_publish_scp_path" ]]; then
    ssh -t "$remote" "cd $remote_path/repo && rm -rf $deploy_publish_scp_path"
    scp "$FILE_STAGE" "$remote:$remote_path/repo/$FILE_STAGE"
    if [[ -f "$DIR/.deploy/hooks.yml" ]]; then
      scp "$DIR/.deploy/hooks.yml" "$remote:$remote_path/repo/.deploy/hooks.yml"
    fi
    scp -r "$deploy_publish_scp_path" "$remote:$remote_path/repo/"
  elif [[ "$deploy_publish_script" ]]; then
    ${deploy_publish_script}
  fi

  ssh -t "$remote" "cd $remote_path/ && paliari-deploy release"

  echo
  echo_green "PUBLISHED '$APP_STAGE' -------------------------"
  echo
}
# --------------------

# Release
release() {
  DIR=$(pwd)
  version=${1:-$(date +%s)}

  echo
  echo_blue 'START SERVER RELEASE-----------------------'
  echo

  # Validate repo path exists in the APP
  if [[ ! -d "repo" ]]; then
    echo_red "Repo not found in '$DIR'!"
    exit 1
  fi

  if [[ -f "$DIR/repo/.deploy/hooks.yml" ]]; then
    yaml_create_variables "$DIR/repo/.deploy/hooks.yml"
  fi

  # Exec hook in the repo
  if [[ "${deploy_hooks_repo[*]}" ]]; then
    cd repo/
    for i in ${!deploy_hooks_repo[*]}; do
      call=${deploy_hooks_repo[$i]}
      echo_yellow "exec: [$call] in the repo"
      ${call}
    done
  fi
  echo
  cd "$DIR"

  # Create release version
  mkdir -p "releases/$version"
  echo "Repo copy to releases/$version"
  cp -a repo/* "releases/$version/"
  # Link shared in release
  if [[ -d "shared" ]]; then
    for f in shared/* shared/.env; do
      if [[ -f "$f" ]]; then
        ln -sf "$DIR/$f" "$DIR/releases/$version/"
      fi
    done
    echo_green "Created shared links in releases/$version/"
  fi
  echo

  # Exec hooks in the release
  if [[ "${deploy_hooks_releases[*]}" ]]; then
    cd "releases/$version/"
    for i in ${!deploy_hooks_releases[*]}; do
      call=${deploy_hooks_releases[$i]}
      echo_yellow "exec: [$call] in the release"
      ${call}
    done
  fi
  echo
  cd "$DIR"

  # Link current in the release version
  set_current_release "$version"
  gc_releases

  echo
  echo_blue 'FINISHED SERVER RELEASE--------------------'
  echo
}
# --------------------

# List releases
releases() {
  FILE_STAGE=".deploy/stage-$1.yml"
  if [[ ! -f "$FILE_STAGE" ]]; then
    echo_red "Config file '$FILE_STAGE' not found!"
    exit 1
  fi

  yaml_create_variables "$FILE_STAGE"

  remote="$deploy_remote_user@$deploy_remote_host"
  remote_path="$deploy_remote_path"

  ssh -t "$remote" "cd $remote_path/ && paliari-deploy releases-list"
}
# --------------------

# List releases
releases_list() {
  # Check releases path exists in the APP
  if [[ ! -d "releases" ]]; then
      echo_red "Releases path not found in '$(pwd)'"
      exit 1
  fi

  ls -lt releases/ | awk '{print $9, $6, $7, $8}'
  echo
}
# --------------------

# Rollback
rollback() {
  FILE_STAGE=".deploy/stage-$1.yml"
  version=$2

  echo_green "Start Rollback --------------------------------"

  if [[ ! -f "$FILE_STAGE" ]]; then
    echo_red "Config file '$FILE_STAGE' not found!"
    exit 1
  fi
  # Validate Release path exists in the APP
  if [[ ! "$version" ]]; then
    echo "Release version is required!"
    exit 1
  fi

  yaml_create_variables "$FILE_STAGE"

  remote="$deploy_remote_user@$deploy_remote_host"
  remote_path="$deploy_remote_path"

  ssh -t "$remote" "cd $remote_path/ && paliari-deploy set-current-release $version"

  echo
  echo_green "Rollback Finished -----------------------------"
  echo
}
# --------------------

# Set current release
set_current_release() {
  DIR=$(pwd)
  version=$1

  echo_yellow "Replece releases/$version to current"

  # Validate APP path exists
  if [[ ! -d "$DIR/releases" ]]; then
      echo_red "Path releases not found!"
      echo
      exit 1
  fi

  # Validate Release path exists in the APP
  if [[ ! "$version" || ! -d "releases/$version" ]]; then
    echo "Release version '$version' not found in '$DIR'"
    exit 1
  fi

  # Link current in the release version
  cp -a "$DIR/releases/$version" "$DIR/current_tmp"
  mv current current_old
  mv current_tmp current
  rm -rf current_old

  echo_green "Linked current to '$version'"
  echo
}
# --------------------

# Help
help() {
  echo
  echo "Usage:"
  echo "$ paliari-deploy <action> <stage> <other-options>"
  echo
  echo "See docs in the project:"
  echo "https://github.com/paliari-ti/paliari-deploy"
  echo
}
# --------------------

# Deploy Actions
case ${1} in
  init)                init ${2} ;;
  publish)             publish ${2} ;;
  release)             release ${2} ;;
  releases)            releases ${2} ;;
  rollback)            rollback ${2} ${3} ;;
  releases-list)       releases_list ;;
  set-current-release) set_current_release ${2} ;;
  --help|-h)           help ;;
  *) echo_red "Action not found!"; help; exit 1 ;;
esac
