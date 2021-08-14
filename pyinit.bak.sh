#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
  	# shellcheck shell=bash
  	# shellcheck source=/dev/null
  	# shellcheck disable=2178,2128,2206,2034
	#? #################  pyinit - initialize new python project  ###############
 	#* copyright (c) 2019 Michael Treanor     -----     MIT License
 	#? ###################### https://www.github.com/skeptycal ##################


	#* REFERENCE:
	#* THIS IS A COPY OF THE INIT SCRIPT FOR PYTHON PROJECTS THAT IS LOCATED
	#* IN THE ~/bin directory and is on the PATH.

#? --------------------------------> utilities
	opexec () {
		desc="$1"; shift;
		op="$@"
		vecho "$desc"
		eval $op || die "Error with operation: $desc"
	}
	# init virtual environment
	venvinit () {
		if [ -d $DEFAULT_ENVIRONMENT_FOLDER_NAME ]; then
			attn "$DEFAULT_ENVIRONMENT_FOLDER_NAME already exists ... skipping creation."
		else
			opexec "Install Python3 virtual environment." "python3 -m venv $DEFAULT_ENVIRONMENT_FOLDER_NAME --symlinks"
		fi
		}

	# activate virtual environment
	sba () { opexec "Activate virtual environment" ". ${DEFAULT_ENVIRONMENT_FOLDER_NAME}/bin/activate"; }

	# pip install
	piu () { for arg in $@; do opexec "Pip install/upgrade $arg" "python3 -m pip install -U $arg"; done; }

	# poetry add
	pa () {
		for arg in $@; do
			echo "arg: $arg"
			opexec "Install Poetry Dependencies: $arg" "poetry add $arg"
		done
		}

	# poetry add devtools
	pd () {
		for arg in $@; do
			echo "arg: $arg"
			opexec "Install Poetry DEV Dependencies: $arg" "poetry add -D $arg"
		done
		}

	# check for required dependencies
	checkenv() {
        doordie git
		doordie python3
		doordie pip
		exists poetry || piu poetry
		doordie poetry
	}

    gi () {
        curl -fLw '\n' https://www.gitignore.io/api/"${(j:,:)@}"
    }

#? --------------------------------> defaults and os utilities
	. ansi_colors.sh || vecho "no ansi colors available"

	VERBOSE="yes"
	MIN_PY_VERSION="3.8"

	PARENT=${PWD%/*}
	DEFAULT_ENVIRONMENT_FOLDER_NAME=".venv"

	NAME=${PWD##*/}
	DESC="Utilities for macOS Python and Go project management by Michael Treanor"
	LICENSE="MIT"
	AUTHOR="Michael Treanor"
	AUTHOR_EMAIL="$AUTHOR <skeptycal@gmail.com>"
	PR_EMAIL="skeptycal <26148512+skeptycal@users.noreply.github.com>"
	AUTHOR_LINK="https://github.com/skeptycal"

	DEFAULT_DEPS= #( requests pandas )
	DEFAULT_DEV_DEPS=( pylint pytest mypy )

	[[ $# -gt 0 ]] && DESC="$@"

	die () { warn "$@" >&2; exit 1; }
	exists () { command -v $1 > /dev/null 2>&1; }
	doordie () { exists $1 || die "Required dependency not found: $@"; }
	vecho () { [ -n $VERBOSE ] && blue "$@"; }

#? --------------------------------> init script
	# create default pyproject.toml if (non-zero size) file is not present.
	defaulttoml () {
		[ -s pyproject.toml ] || cat <<- TOML >pyproject.toml
			[tool.poetry]
			name = "$NAME"
			version = "0.1.0"
			description = "$DESC"
			authors = ["$PR_EMAIL"]
			license = "$LICENSE"

			[tool.poetry.dependencies]
			python = "^$MIN_PY_VERSION"

			[tool.poetry.dev-dependencies]

			[build-system]
			requires = ["poetry-core>=1.0.0"]
			build-backend = "poetry.core.masonry.api"
		TOML
	}

	main() {
		me "Python Project Initialization"
		me "============================="
		me "Parent Directory: $PARENT"
		me "Project Name: $NAME"
		me "Project Description: $DESC"
		me "Project License: $LICENSE"
		me "Author Email: $PR_EMAIL"

		checkenv

		git init
        [ -s .gitignore ] || gi python macos windows linux >|.gitignore

		defaulttoml "$DESC"
		venvinit
		sba
		piu pip
		piu setuptools wheel

		pa $DEFAULT_DEPS
		me "Poetry DEV Dependencies: $DEFAULT_DEV_DEPS"
		pd $DEFAULT_DEV_DEPS

		poetry update

        git add --all --
        git commit -m "Initial Commit"
        git status
	}

main "$@"
