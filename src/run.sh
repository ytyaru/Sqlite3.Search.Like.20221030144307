#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# monaledge.dbをlike句で検索する。
# CreatedAt: 2022-10-30
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	ParseCommand() {
		THIS_NAME=`basename "$BASH_SOURCE"`
		SUMMARY='monaledge.dbをlike句で検索する。'
		VERSION=0.0.1
		Help() { eval "echo -e \"$(cat help.txt)\""; }
		Version() { echo "$VERSION"; }
		while getopts ":hvfo:" OPT; do
		case $OPT in
			h) Help; exit 0;;
			v) Version; exit 0;;
		esac
		done
		shift $(($OPTIND - 1))
		ParseSubCommand() {
			case $1 in
			-h|--help|help) Help; exit 0;;
			-v|--version|version) Version; exit 0;;
			esac
		}
		[ $# -eq 0 ] && { Error '位置引数は必須です。第一引数に検索ワードを指定してください。'; Help; exit 1; } || :;
		ParseSubCommand "$@"
	}
	ParseCommand "$@"
	DB=monaledge.db
	Like() { L=; for v in "$@"; do { L+=" content like '%$v%' and"; } done; echo "${L%and}"; }
	Sql() { sqlite3 -batch -tabs "$DB" "$1"; }
	SQL="select count(*) from articles where $(Like "$@");"
	ALL_COUNT="$(Sql "select count(*) from articles;")"
	HIT_COUNT="$(Sql "$SQL")"
	SQL="select id, title, replace(replace(replace(replace(substr(content, max(0, instr(content, '$1') - 15), 30), '$1', '<mark>$1</mark>'), char(10), ''), char(13), ''), char(9), '') from articles where $(Like "$@");"
	#SQL="select id, title, replace(replace(replace(substr(content, max(0, instr(content, '$1') - 15), 30), '$1', '<mark>$1</mark>'), char(10), ''), char(9), '') from articles where $(Like "$@");"
	#SQL="select id, title, replace(substr(content, max(0, instr(content, '$1') - 15), 30), '$1', '<mark>$1</mark>') from articles where $(Like "$@");"
	#echo "$SQL"
	#SQL="select id, title, replace(substr(content, max(0, instr(content, '$1') - 15), 30), '$1', '<mark>$1</mark>') from articles where content like '%$1%';"
	echo -e "$HIT_COUNT\t$ALL_COUNT"
	Sql "$SQL"
}
Run "$@"
