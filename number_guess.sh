#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

main_menu () {
  echo "Enter your username:"
  read USERNAME

  USER_DATA=$($PSQL "SELECT games_played, best_game FROM game WHERE username='$USERNAME'")

  if [[ -z $USER_DATA ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO game(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  else
    echo "$USER_DATA" | while IFS="|" read GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi
  
  echo "Guess the secret number between 1 and 1000:"
  COUNTER=0
  
  while true; do
    read GUESS_NUMBER
    ((COUNTER++))

    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS_NUMBER -eq $RANDOM_NUMBER ]]
    then
      echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
      
      UPDATE_GAMES=$($PSQL "UPDATE game SET games_played = games_played + 1 WHERE username='$USERNAME'")
      
      CURRENT_BEST=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
      if [[ $CURRENT_BEST -eq 0 || $COUNTER -lt $CURRENT_BEST ]]
      then
        UPDATE_BEST=$($PSQL "UPDATE game SET best_game = $COUNTER WHERE username='$USERNAME'")
      fi
      break
    elif [[ $GUESS_NUMBER -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  done
}

main_menu