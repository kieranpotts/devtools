#!/bin/bash

# Note: the "library" repo has been removed to save local disk space. This repo is best managed directly upstream.
repos=("archive" "blog" "cheats" "dotfiles" "garden" "kieranpotts" "linters" "process" "standards" "tools" "hacksjs/decisions" "hacksjs/hacksjs" "nirvarnia/decisions" "nirvarnia/nirvarnia" "nirvarnia/prototypes" "srcflow/srcflow")

# Local paths are relative to the user's `~/dev` root.
declare -A local_paths
local_paths["archive"]="personal/archive"
local_paths["blog"]="personal/blog"
local_paths["cheats"]="personal/cheats"
local_paths["dotfiles"]="personal/dotfiles"
local_paths["garden"]="personal/garden"
local_paths["kieranpotts"]="personal/kieranpotts"
local_paths["linters"]="personal/linters"
local_paths["process"]="personal/process"
local_paths["standards"]="personal/standards"
local_paths["tools"]="personal/tools"
local_paths["hacksjs/decisions"]="projects/hacksjs/decisions"
local_paths["hacksjs/hacksjs"]="projects/hacksjs/hacksjs"
local_paths["nirvarnia/decisions"]="projects/nirvarnia/decisions"
local_paths["nirvarnia/nirvarnia"]="projects/nirvarnia/nirvarnia"
local_paths["nirvarnia/prototypes"]="projects/nirvarnia/prototypes"
local_paths["srcflow/srcflow"]="projects/srcflow/srcflow"

declare -A remote_urls
remote_urls["archive"]="git@github.com:kieranpotts/archive.git"
remote_urls["blog"]="git@github.com:kieranpotts/blog.git"
remote_urls["cheats"]="git@github.com:kieranpotts/cheats.git"
remote_urls["dotfiles"]="git@github.com:kieranpotts/dotfiles.git"
remote_urls["garden"]="git@github.com:kieranpotts/garden.git"
remote_urls["kieranpotts"]="git@github.com:kieranpotts/kieranpotts.git"
remote_urls["linters"]="git@github.com:kieranpotts/linters.git"
remote_urls["process"]="git@github.com:kieranpotts/process.git"
remote_urls["standards"]="git@github.com:kieranpotts/standards.git"
remote_urls["tools"]="git@github.com:kieranpotts/tools.git"
remote_urls["hacksjs/decisions"]="git@github.com:hacksjs/decisions.git"
remote_urls["hacksjs/hacksjs"]="git@github.com:hacksjs/hacksjs.git"
remote_urls["nirvarnia/decisions"]="git@github.com:nirvarnia/decisions.git"
remote_urls["nirvarnia/nirvarnia"]="git@github.com:nirvarnia/nirvarnia.git"
remote_urls["nirvarnia/prototypes"]="git@github.com:nirvarnia/prototypes.git"
remote_urls["srcflow/srcflow"]="git@github.com:srcflow/srcflow.git"

declare -A main_branches
main_branches["archive"]="main"
main_branches["blog"]="dev"
main_branches["cheats"]="main"
main_branches["dotfiles"]="dev"
main_branches["garden"]="main"
main_branches["kieranpotts"]="main"
main_branches["linters"]="init"
main_branches["process"]="init"
main_branches["standards"]="init"
main_branches["tools"]="dev"
main_branches["hacksjs/decisions"]="dev"
main_branches["hacksjs/hacksjs"]="init"
main_branches["nirvarnia/decisions"]="dev"
main_branches["nirvarnia/nirvarnia"]="init"
main_branches["nirvarnia/prototypes"]="dev"
main_branches["srcflow/srcflow"]="init"
