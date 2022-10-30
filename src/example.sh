#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# 全文検索。
# CreatedAt: 2022-10-30
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	./run.sh モナコイン マイニング
	
	#echo -e "$(./run.sh モナコイン マイニング)" | cut -f2
}
Run "$@"
