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

# git && blih
blih_select=""
git_branch_select=""
git_branch=""
# git_url=$(git ls-remote --get-url)

# param
user_name=""
git_name=""

# Check if actual repo is a git repository
# It could be an unvalid git repo but this is not checked

is_git() {
  if [ ! -d ./.git ]
  then
    echo -e "${orange}Git repo : ${red}No git repository found.${white}"
    return 1
  else
    echo -e "${orange}Git repo : ${blue}$(git ls-remote --get-url)${white}"
  fi
}

get_login() {
  declare -i xx=0
  tmp=$user_name
  while [ $xx -eq 0 ] || [ -z $user_name ]
  do
    user_name=$(whiptail --title "Config" --inputbox "Username (using blih you must enter your login)" \
    9 60 $tmp \
    3>&1 1>&2 2>&3)
    if [ $? -gt 0 ]
    then
      return 1
    fi
    let xx=1
  done

  password=""
  while [ -z $password ]
  do
    password=$(whiptail --title "Config" --passwordbox "Password" \
    9 60 \
    3>&1 1>&2 2>&3)
    if [ $? -gt 0 ]
    then
      return 1
    fi
  done
}

create_git() {
  answer=$(whiptail --title "Git repository" --checklist "Choose an option (Space to (de)select)" \
  20 60 2 \
  "1" "Using blih (You mush have blih installed)" OFF \
  "2" "Clone repository in current directory ?" ON \
  3>&1 1>&2 2>&3)
  if [ $? -gt 0 ]
  then
    return
  fi

  get_login
  if [ $? -ne 0 ]
  then
    return
  fi

  let xx=0
  while [ $xx -eq 0 ] || [ -z $git_name ]
  do
    git_name=$(whiptail --title "Config" --inputbox "Repository name" \
    9 60 $git_name \
    3>&1 1>&2 2>&3)
    if [ $? -gt 0 ]
    then
      return 1
    fi
    if [ ! -z $git_name ] && [ -d $git_name ]
    then
      whiptail --title "Clone" --msgbox "Repository $git_name already exist." \
      9 60
      git_name=""
    fi
    let xx=1
  done

# git init git commit git remote add origin url || curl
# blih
# Check if blih exist RETURN CODE 127
# Je dois choisir sur quel méthode on créer un repo git api ou cli
  git_url=""
  echo $answer | grep "1" >> /dev/null
  if [ $? -eq 0 ]
  then
    tmp=`echo -n $password | shasum -a 512`
    for opt in $tmp
    do
      if [ $opt != "-" ]
      then
        blih -u $user_name -t $opt repository create $git_name >> /dev/null # 1 is fail 0 is ok
      fi
    done
  else
    curl https://$user_name:$password@api.github.com/user/repos \
    -d "{\"name\":\"$git_name\"}" >> /dev/null # grep error to check if there is error
  fi
  echo $answer | grep "2" >> /dev/null
  if [ $? -eq 0 ]
  then
    git clone $git_url --quiet
    if [ -d $git_name ]
    then
      echo -e "${orange}Git repo : ${blue}Repository successfully cloned !${white}"
      cd $git_name
      whiptail --title "Clone" --msgbox "Switch to git repository $git_name." \
      9 60
    else
      echo -e "${orange}Git repo : ${red}Clone failed !${white}"
      whiptail --title "Clone" --msgbox "Clone failed, check your param's." \
      9 60
    fi
  fi
}

clone() {
  echo "Ouai j'dois faire le clone :'("
}

get_branch() {
  branchOutput=`git for-each-ref refs/heads/ | head -n 10`
  let xx=0

  for branch in $branchOutput #Parse branch to get branch name
  do
    xx=`expr $xx + 1`
    branchName=`echo "$branch" | sed 's/.*refs\/heads\///'`

    if [ `expr $xx % 3` -eq 0 ]
    then
      git_branch+=`expr $xx / 3`
      git_branch+=" "
      git_branch+=$branchName
      git_branch+=" "
    fi
  done
  branch_nb=`git for-each-ref refs/heads/ | wc -l`
  git_branch_select=$(whiptail --title "Branch Select" --menu "Choose the branch you want to use" \
  20 60 \
  10 $git_branch 3>&1 1>&2 2>&3)
  if [ -z $git_branch_select ]
  then
    echo -e "${orange}Git branch : ${red}none branch selected.${white}"
    return
  fi
  let xx=0
  for branch in $git_branch #Parse tags to get branch name
  do
  xx=`expr $xx + 1`
    if [ $xx -eq $(($git_branch_select*2)) ]
    then
      git_branch_select=$branch
      break;break
    fi
  done
  git checkout $git_branch_select --quiet
  echo -e "${orange}Git branch : ${blue}branch $git_branch_select selected !${white}"
}

contributor() {
  echo "Tellement pas fait"
}

pull() {
  echo "A AMELIORER !!!!"
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
  echo "Push non fait :3"
  return
}

non_git_menu() { #Lets's going here if we are not in a git repo
  want_git=$(whiptail --title "Non git repository" --menu "Choose an option" \
  9 60 1 \
  "1" "Create repository" 3>&1 1>&2 2>&3)
  echo $want_git
  if [ -z $want_git ]
  then
    echo -e "${orange}Build : ${red}Thanks to use my script ! :)${white}"
    exit
  fi
  create_git
  git_menu
}

git_menu() { #Menu when we are in a git repository
  answer=$(whiptail --title "Git repository" --menu "Choose an option" \
  14 60 6 \
  "1" "Create repository" \
  "2" "Clone repository" \
  "3" "Checkout branch" \
  "4" "Add contributor" \
  "5" "Pull" \
  "6" "Push" 3>&1 1>&2 2>&3)
  if [ -z $answer ]
  then
    if [ ! $git_branch_select == "master" ]
    then
      echo -e "${orange}Git branch : ${blue}If you want to checkout your origin banch, use 'git checkout master'.${white}"
    fi
    echo -e "${orange}Build : ${red}Thanks to use my script ! :)${white}"
    exit
  fi
  case $answer in
    "1") create_git
    ;;
    "2") clone
    ;;
    "3") get_branch
    ;;
    "4") contributor
    ;;
    "5") pull
    ;;
    "6") push
    ;;
  esac
  git_menu
}

# Considered as main of script shell
build() {
  is_git
  if [ $? -eq 1 ]
  then
    non_git_menu
  else
    git_menu
  fi

  if [ ! $git_branch_select == "master" ]
  then
    echo -e "${orange}Git branch : ${blue}If you want to checkout your origin banch, use 'git checkout master'.${white}"
  fi
  echo -e "${orange}Build : ${red}Thanks to use my script ! :)${white}"
}

clear
build $*
