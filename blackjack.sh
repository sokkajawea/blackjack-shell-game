#!/bin/bash

#possible card values in an array
cards=(2 3 4 5 6 7 8 9 10 J Q K A)

# function to generate a random card from the array cards
function draw_card {
  echo ${cards[$((RANDOM%13))]}
}

# function to calculate the total value of a hand
function calculate_hand {
  local hand=$1
  local total=0
  local num_aces=0

  # calculate total value of hand, keeping track of the number of aces
  for card in $hand; do
    if [ "$card" == "A" ]; then
      total=$((total+11))
      num_aces=$((num_aces+1))
    elif [ "$card" == "J" ] || [ "$card" == "Q" ] || [ "$card" == "K" ]; then
      total=$((total+10))
    else
      total=$((total+card))
    fi
  done

  # if total is over 21, convert aces to value 1 until total is 21 or below
  while [ "$total" -gt 21 ] && [ "$num_aces" -gt 0 ]; do
    total=$((total-10))
    num_aces=$((num_aces-1))
  done

  echo $total
}

# function to check if a hand is a bust (over 21) 
function is_bust {
  local total=$(calculate_hand "$1")
  if [ "$total" -gt 21 ]; then
    echo 1
  else
    echo 0
  fi
}

# main game loop as long as user chooses y
while true; do
  # deal initial cards to dealer and player 2 cards each
  dealer_hand=$(draw_card)
  player_hand=$(draw_card)
  dealer_hand="$dealer_hand $(draw_card)"
  player_hand="$player_hand $(draw_card)"
  if [ "$player_hand" == "A" ]; then 
  read -p "High or low ace? (h/l) " ace_choice
  case "$ace_choice" in 
  l)
  player_hand=1
  ;;
  h)
  player_hand=11
  ;;
  *)
  echo "Input invalid, ace counted as a 1"
  player_hand=1
  ;;
  esac
  fi 
  #calculate the new total to then display it in brackets in the initial hands display
  dealer_total=$(calculate_hand "$dealer_hand")
  player_total=$(calculate_hand "$player_hand")
  
  
echo ""  
echo "----Welcome To BlackJack at the Royal Casino----"  
echo ""

  # show initial hands
  echo "Dealer's hand: $dealer_hand ($dealer_total)"
  echo "Your hand: $player_hand ($player_total)"
  #check if the player has blackjack on the spot
  if [ "$player_total" -eq 21 ]; then 
  echo "You have blackjack! You win!"
  read -p "Play again? (y/n) " choice
  case "$choice" in
    y)
      continue
      ;;
    n)
      break
      ;;
    *)
      echo "Invalid input. Please enter y or n."
      ;;
  esac
  fi
  #check if the dealer has blackjack on the spot
  if [ "$dealer_total" -eq 21 ]; then
  echo "Dealer has blackjack! You lose!"
  read -p "Play again? (y/n) " choice
  case "$choice" in
    y)
      continue
      ;;
    n)
      break
      ;;
    *)
      echo "Invalid input. Please enter y or n."
      ;;
  esac
 fi
  
# player's turn
  while true; do
    read -p "Hit or stand? (h/s) " choice
    case "$choice" in
      h)
      new_card=$(draw_card)   
        if [ "$new_card" == "A" ]; then
          read -p "Low or high ace? (l/h) " ace_choice
          case "$ace_choice" in
            l)
              new_card=1
              ;;
            h)
              new_card=11
              ;;
            *)
              echo "Invalid input. Ace will be counted as 1."
              new_card=1
              ;;
          esac
        fi
        player_hand="$player_hand $new_card"
        player_total=$(calculate_hand "$player_hand")
        echo "Your hand: $player_hand ($player_total)"
        if [ "$player_total" -eq 21 ]; then 
        echo "You have 21! You win!"
        break
        fi
        if [ "$(is_bust "$player_hand")" -eq 1 ]; then
          echo "You bust! Dealer wins."
          break
        fi
        ;;
      s)
        break
        ;;
      *)
        echo "Invalid input. Please enter h or s."
        ;;
    esac
  done

# function to compare two hands and determine the winner
function compare_hands {
  local dealer_total=$(calculate_hand "$1")
  local player_total=$(calculate_hand "$2")

  if [ "$player_total" -gt 21 ]; then
    echo "You lose :( Dealer wins."
  elif [ "$dealer_total" -gt 21 ]; then
    echo "Dealer busts! You win!"
  elif [ "$player_total" -gt "$dealer_total" ]; then
    echo "You win!"
  elif [ "$player_total" -lt "$dealer_total" ]; then
    echo "Dealer wins."
  else
    echo "It's a tie!"
  fi
}


  # if player did not bust, dealer's turn
  if [ "$(is_bust "$player_hand")" -eq 0 ]; then
    while true; do
      dealer_total=$(calculate_hand "$dealer_hand")
      if [ "$dealer_total" -ge 17 ]; then
        break
      else
        dealer_hand="$dealer_hand $(draw_card)"
      fi
    done

    # show final hands and determine winner
    echo "Dealer's hand: $dealer_hand ($dealer_total)"
    echo "Your hand: $player_hand ($player_total)"
    if [ "$dealer_total" -eq 21 ]; then
      echo "Dealer has 21! Dealer wins."
    elif [ "$dealer_total" -gt 21 ]; then
      echo "Dealer busts! You win!"
    elif [ "$dealer_total" -gt "$player_total" ]; then
      echo "Dealer wins."
    elif [ "$dealer_total" -lt "$player_total" ]; then
      echo "You win!"
    else
      echo "It's a tie!"
    fi
  fi
#prompt the user to play the game again
  read -p "Play again? (y/n) " choice
  case "$choice" in
    y)
      continue
      ;;
    n)
      break
      ;;
    *)
      echo "Invalid input. Please enter y or n."
      ;;
  esac
done
