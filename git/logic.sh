#!/usr/bin/env bash

function git_submodule_has_branch_conf() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		return 2
	fi
	local branch_submodule="$(git_branch_submodule_conf "${submodule}")"
	if [ $(echo "${branch_submodule}" | wc -w) -eq 0 ]; then
		return 1
	fi
	return 0
}
export -f git_submodule_has_branch_conf

function git_submodule_is_on_branch_conf() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 1
	fi
	local branch_submodule="$(git_branch_submodule_conf "${submodule}")"
	local branch_selected="$(git_branch_submodule_local "${submodule}")"
	test "${branch_submodule}" = "${branch_selected}"; local ret=$?
	return ${ret}
}
export -f git_submodule_is_on_branch_conf

function git_submodule_is_head_detached() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 1
	fi
	local branch_selected="$(git_branch_submodule_local "${submodule}")"
	test "(HEAD detached at" = "${branch_selected:0:17}"; local ret=$?
	return ${ret}
}
export -f git_submodule_is_head_detached

function git_submodule_init() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 0
	fi
	git submodule init "${submodule}"
	return 0
}
export -f git_submodule_init

function git_submodule_branch_state() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 1
	fi

	local branch_selected="$(git_branch_submodule_local "${submodule}")"
	local branch_state=$(git_submodule_exec "${submodule}" "git_branch_state \"${branch_selected}\"")
	echo "Submodule: \"${submodule}\" for branch: \"${branch_selected}\" status: \"${branch_state}\""
	return 0
}

function git_submodule_update() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 1
	fi
	git_submodule_has_branch_conf "${submodule}"; local ret1=$?
	if [ ${ret1} -eq 0 ]; then
		git_submodule_is_on_branch_conf "${submodule}"; local ret2=$?
		git_submodule_is_head_detached "${submodule}"; local ret3=$?
		if [ ${ret2} -eq 0 ] || [ ${ret3} -eq 0 ] ; then
			echo "Submodule: \"${submodule}\" would do automatic submodule update for new changes from remote"
			_=$(git_branch_submodule_conf "${submodule}"); local ret=$?
			if [ ${ret} -eq 0 ]; then
				git submodule update --remote --merge --recursive "${submodule}"
			else
				git submodule update --merge --recursive "${submodule}"
			fi
			git_submodule_branch_state "${submodule}"
		else
			echo "Submodule: \"${submodule}\" won't do automatic submodule update for new changes, but only fetch, as it's not on remote branch or detached"
			git_submodule_exec "${submodule}" git fetch
			git_submodule_branch_state "${submodule}"
		fi
	else
		echo "Submodule: \"${submodule}\" won't do automatic submodule update for new changes, as there are no submodule branche configured"
	fi
	return 0
}
export -f git_submodule_update

function git_submodule_refresh() {
	local submodule="$1"
	if [ $(echo "${submodule}" | wc -w) -eq 0 ]; then
		echo ""
		return 0
	fi
	# Register submodules in .git
	git_submodule_init "${submodule}"

	# Update submodules
	git_submodule_update "${submodule}"
}

