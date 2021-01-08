#!/bin/bash

build_type=""
version_file=""

while getopts ":b:o:" flag; do
case "${flag}" in
        b)
            build_type=$OPTARG
            ;;
        o)
            version_file=$OPTARG
            ;;
        *)
            ;;
esac
done

echo "build_type = $build_type"
echo "version_file=$version_file"

PROTO_FILES_REL=""
PROTO_FILES_ABS=""

PROTO_PACKAGE_NAME=$(cat ./.pbrepo/config.yaml | yq -c -j '."package-name"')

for item in $(cat ./.pbrepo/config.yaml | yq -c '.filters[]'); do
  filter=$(echo $item | jq -j '.')
  temp_rel=$(find . -regex "$filter" -not -path "./.pbrepo/*")
  temp_abs=$(find . -regex "$filter" -not -path "./.pbrepo/*" -exec readlink -f {} \;)
  PROTO_FILES_REL="$PROTO_FILES_REL $temp_rel"
  PROTO_FILES_ABS="$PROTO_FILES_ABS $temp_abs"
done

echo PROTO_FILES_REL=$(echo "$PROTO_FILES_REL" | tr "\n" " ")
echo PROTO_FILES_ABS=$(echo "$PROTO_FILES_ABS" | tr "\n" " ")

PROTO_FILES_REL=$(echo "$PROTO_FILES_REL" | tr "\n" " ")
PROTO_FILES_ABS=$(echo "$PROTO_FILES_ABS" | tr "\n" " ")

export BUILD_MAJOR_VERSION=$(cat .pbrepo/version | head -n 1)
export BUILD_REVISION=$(git rev-list --count HEAD)
export BUILD_GIT_ORIGIN_URL=$(git config --get remote.origin.url)

export PROTO_FILES_REL
export PROTO_FILES_ABS

export PROTO_PACKAGE_NAME

function runCommands() {
  local item_type=$1
  local dir=$2
  local commands=$3

  cd "$dir"

  local cmds=$(echo $commands | jq -c '.[]')
  local cmdarr=()

  while IFS= read -r cmd; do
    cmdarr+=("$cmd")
  done <<< "$cmds"

  for (( i=0; i<${#cmdarr[@]}; i++ )); do
    scmd=$(echo ${cmdarr[$i]} | jq -cj '.')
    echo "exec$ $scmd"
    ( eval $scmd )
  done
}

function getJavaOutputVersion() {
  dir=$1

  cd "$dir"

  find build/libs/*.jar | sed -r 's/^.*-([0-9.]+)\.jar$/\1/g'
}

function getNodePackageConfig() {
  dir=$1
  key=$2
  cd "$dir"
  cat package.json | jq -jc '.'$key
}

pipeline=$(cat ./.pbrepo/config.yaml | yq -c '.pipeline[]')
pwd=$PWD
while IFS= read -r item; do
  item_type=$(echo $item | jq -j '.type')
  item_path=$(echo $item | jq -j '.path')
  item_src_path=$(echo $item | jq -j '.srcPath')
  item_commands=$(echo $item | jq -c '.commands')

  item_abs_path=${pwd%%/}/$item_path

  if [[ "x$build_type" == "x" || "x$build_type" == "x$item_type" ]]; then
    runCommands "$item_type" "$item_abs_path" "$item_commands"

    version=""
    [ "$item_type" == "java" ] && version=$(getJavaOutputVersion "$item_abs_path")
    [ "$item_type" == "javascript" ] && version=$(getNodePackageConfig "$item_abs_path" "name")@$(getNodePackageConfig "$item_abs_path" "version")

    if [ "x$version_file" != "x" ]; then
      echo $version > $version_file
    fi
  fi
done <<< "$pipeline"
