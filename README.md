# Casino

Playing around with applications to try to create a blackjack game.

## Things of note:
- [GameManager.Start](https://github.com/gogogarrett/casino/blob/master/apps%2Fgame_manager%2Flib%2Fgame_manager%2Fstart.ex) - kicks off the main logic
  - start table and build deck + shuffle
  - start table state machine to handle game logic
  - simulate four players joining
    - start up a player gen server with a reference to the table_id
    - hack to give players each their own info
    - Fetch the player info
    - Notify the state machine that players have joined
  - Increase the uuid for the id counter for the next game
- [GameManager.Table.StateMachine](https://github.com/gogogarrett/casino/blob/master/apps%2Fgame_manager%2Flib%2Fgame_manager%2Ftable%2Fstate_machine.ex) - handles the game state
  - player_joined
  - player_left
  - switches from `waiting` -> `playing` state
  - allows to fetch `current_player`
  - allows to switch to the `next_player`
- [GameManager.Player.Player](https://github.com/gogogarrett/casino/blob/master/apps%2Fgame_manager%2Flib%2Fgame_manager%2Fplayer%2Fplayer.ex) - basic player
  - allows to `get_info`
  - can `add_player_info` about a specific player (name, etc)
  - can call `hit` to fetch a new card
    - This will return your current deck, newest card, and total handle count
  - can call `stay` to change the table's state_machine to the next player
- [TableManager.Table.Card](https://github.com/gogogarrett/casino/blob/master/apps%2Ftable_manager%2Flib%2Ftable_manager%2Ftable%2Fcard.ex) - a simple card in a deck of cards
  - has a `value` function to return the value of a given card
  - note: returns [1, 11] for ace
- [TableManager.Table.DeckBuilder](https://github.com/gogogarrett/casino/blob/master/apps%2Ftable_manager%2Flib%2Ftable_manager%2Ftable%2Fdeck_builder.ex) - builds a deck of cards
- [TableManager.Table.Hand](https://github.com/gogogarrett/casino/blob/master/apps%2Ftable_manager%2Flib%2Ftable_manager%2Ftable%2Fhand.ex) - representation of a hand for a specific game
  - has a `count` function given a hand to compute the value for a given hand
  - You can pass a second argument to count to count ace as high
- [TableManager.Table.Dealer](https://github.com/gogogarrett/casino/blob/master/apps%2Ftable_manager%2Flib%2Ftable_manager%2Ftable%2Fdealer.ex) - deals the cards in a deck
  - the dealer will `shuffle` the cards after starting up
  - `hit` will return the first card from the deck
  - if you ask nicely with `show_deck` the dealer will print the results of the deck currently

```elixir
# Would highly recommend observing everything through the observer
# makes it much more clear what's available to play with
:observer.start

# Start a game
GameManager.Start.create_game

# Get the state of a specific table
GameManager.Table.StateMachine.get_state(1)
# {:playing,
#  [%{cards: [], id: 4, name: "Nay", table_id: 1},
#   %{cards: [], id: 3, name: "Phil", table_id: 1},
#   %{cards: [], id: 2, name: "Bob", table_id: 1},
#   %{cards: [], id: 1, name: "Garrett", table_id: 1}]}

# Find out the current player for a specific table
GameManager.Table.StateMachine.current_player(1)

# Interact with a specific player
GameManager.Player.Player.get_info(1)
# %{cards: [], id: 1, name: "Garrett", table_id: 1}

# Change the players info
GameManager.Player.Player.add_player_info(1, %{name: "Garrett"})

# Hit for a specific player
GameManager.Player.Player.hit(1)
# %{hand: %TableManager.Table.Deck.Hand{cards: [%TableManager.Table.Deck.Card{rank: "8",
#      suit: "D"}]}, hand_count: 8,
#   new_card: %TableManager.Table.Deck.Card{rank: "8", suit: "D"}}
GameManager.Player.Player.hit(1)
# %{hand: %TableManager.Table.Deck.Hand{cards: [%TableManager.Table.Deck.Card{rank: "10",
#     suit: "S"}, %TableManager.Table.Deck.Card{rank: "8", suit: "D"}]},
#   hand_count: 18,
#   new_card: %TableManager.Table.Deck.Card{rank: "10", suit: "S"}}

# Stay for a specific player will return who is the next player to play
GameManager.Player.Player.stay(1)
# %{cards: [], id: 4, name: "Nay", table_id: 1}

# Build a card in a deck
%TableManager.Table.Card{suit: "h", rank: "2"}

# Build a deck
TableManager.Table.DeckBuilder.new
# [%TableManager.Table.Card{rank: "A", suit: "H"},
#  %TableManager.Table.Card{rank: "A", suit: "C"},
#  %TableManager.Table.Card{rank: "A", suit: "D"},
#  %TableManager.Table.Card{rank: "A", suit: "S"},
#  %TableManager.Table.Card{rank: "2", suit: "H"},
#  %TableManager.Table.Card{rank: "2", suit: "C"},
#  ...,

# Build a hand of cards
%TableManager.Table.Hand{cards: [%TableManager.Table.Card{suit: "h", rank: "2"}]}
# %TableManager.Table.Hand{cards: [%TableManager.Table.Card{rank: "2", suit: "h"},
#   %TableManager.Table.Hand{cards: [%TableManager.Table.Card{rank: "3",
#      suit: "c"}]}]}

# Count the value for a hand
hand = %TableManager.Table.Hand{cards: [%TableManager.Table.Card{suit: "h", rank: "2"}, %TableManager.Table.Card{suit: "d", rank: "J"}]}
# %TableManager.Table.Hand{cards: [%TableManager.Table.Card{rank: "2", suit: "h"},
#   %TableManager.Table.Card{rank: "J", suit: "d"}]}
TableManager.Table.Hand.count(hand)
# 12

# Spinning up a dealer
TableManager.Table.Dealer.start_link(1)

# Interacting with a dealer at a table
TableManager.Table.Dealer.hit(1)
# %TableManager.Table.Card{rank: "6", suit: "S"}

# Interacting with a dealer to see the deck
TableManager.Table.Dealer.show_deck(1)
# ["D - 4", "H - 8", "C - 3", "D - 9", "S - 10", "H - A", "C - 5", "D - Q",
#  "H - 6", "S - 9", "D - 8", "D - 7", "S - 3", "C - J", "H - J", "C - 10",
#  "D - J", "C - 7", "S - A", "C - 6", "H - Q", "D - 2", "H - 9", "S - 8",
#  "D - 6", "C - K", "C - 4", "D - 3", "S - 4", "C - Q", "C - 8", "D - K",
#  "D - 10", "D - A", "H - 10", "C - 2", "S - 7", "H - 4", "H - 7", "C - A",
#  "H - 3", "C - 9", "D - 5", "S - 2", "H - K", "S - K", "H - 2", "S - 5",
#  "H - 5", "S - Q", ...]
```
