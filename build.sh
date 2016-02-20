#!/bin/bash


#
# Made by Pierre Monge
# If there any prob's with this script,
# send an e'mail at pierre.monge@epitech.eu
# Thanks
#

# FR :
# Ce script vérifie si vous avez un dossier git local
# Si ce dossier est bien un dossier git, alors le script
# gérera vos push et pull à chaque lancement du script
# Pour récupérer un push git foireux, rien ne vaut un bon gitk des familles

# Escaped char color
red="\e[31m"
orange="\e[33m"
blue="\e[36m"
white="\e[0m"

# git
git_branch_select=""
git_branch=""
# git_url=$(git ls-remote --get-url)

# Check if actual repo is a git repository
# It could be an unvalid git repo but this is not checked
is_git() {
  if [ ! -d ./.git ]
  then
    echo -e "${red}This is not a git repository.${white}"
    return -1
  else
    echo -e "${orange}Git repo : ${blue}$(git ls-remote --get-url)${white}"
  fi
}

branch() {
  branchOutput=`git for-each-ref refs/heads/ | head -n 10`
  declare -a branches
  let xx=0

  for branch in $branchOutput
  do
    xx=`expr $xx + 1`
    branches=("{branches[@]}" "$branch")
    branchName=`echo "$branch" | sed 's/.*refs\/heads\///'`

    if [ `expr $xx % 3` -eq 0 ]
    then
      git_branch+=$branchName
      git_branch+=" "
      git_branch+=`expr $xx / 3`
      git_branch+=" "
    fi
  done
  branch_nb=`git for-each-ref refs/heads/ | wc -l`
  git_branch_select=$(whiptail --title "Branch Select" --menu "Choose the branch you want to use" \
  20 60 \
  $branch_nb $git_branch 3>&1 1>&2 2>&3)
  if [ -z $git_branch_select ]
  then
    echo -e "${orange}Git branch : ${red}none branch selected, exit.${white}"
    exit
  fi
  echo -e "${orange}Git branch : ${blue}branch $git_branch_select selected !${white}"
}

pull() {
  git checkout $git_branch_select --quiet
  git fetch --quiet

  if [ ! $(git rev-parse HEAD) == $(git rev-parse @{u}) ]
  then
    if whiptail --title "Pull requiered" --yes-button "Pull" --no-button "Don't pull" --yesno "Pull is needed, would you like to pull $git_branch_select:" 20 60;then
      git pull --quiet
      if [ $? -eq 0 ]
      then
        echo -e "${orange}Git pull : ${blue}Pull successfull !${white}"
      else
        git pull > build.log
        echo -e "${orange}Git pull : ${red}Pull failed, check build.log${white}"
        exit
      fi
    else
      echo -e "${orange}Git pull : ${blue}Pull none requiered${white}"
    fi
  else
    echo -e "${orange}Git pull : ${blue}Up to date.${white}"
  fi
}

push() {
  return
}

# Considered as main of script shell
build() {
  is_git
  if [ $? -eq -1 ]
  then
    return 1
  fi

  branch
  pull
  push
  if [ ! $git_branch_select == "master" ]
  then
    echo -e "${orange}Git branch : ${blue}If you want to checkout your origin banch, use 'git checkout master'.${white}"
  fi
  echo -e "${orange}Build : ${red}Thanks to use my script ! :)${white}"
}

clear
build $*
