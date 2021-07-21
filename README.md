# How to Play

There are 2 game modes
Global game - 2 players verse each other in the game, they are paired together just by a first come first server principal

Custom game - 2 players can specifically choose to verse each other by specifying the address of the opponent in the functions (chooseRockAgainst(), choosePaperAgainst(), chooseScissorsAgainst())

The Global Game

1. Deposit some ERC20 funds to the contract calling the enterNextRound() function
2. Select a move via calling one of (chooseRock(), choosePaper(), chooseScissors())
3. Wait for another player to also deposit funds and select a move
4. When both moves are in, the total funds wagered by both players will have their funds saved in the contract
5. To Withdraw all winnnings call getWinnings()
6. Alternatively call betWinnings() to use your winnings to enter the next round

The Custom Game

1. Deposit some ERC20 funds to the contract calling the enterNextRound() function
2. Select a move via against your chosen opponent calling one of (chooseRockAgainst(opponentAddress), choosePaperAgainst(opponentAddress), chooseScissorsAgainst(opponentAddress))
3. Wait for opponent to also deposit funds and select a move against you
4. When both moves are in, the total funds wagered by both players will have their funds saved in the contract
5. To Withdraw all winnnings call getWinnings()
6. Alternatively call betWinnings() to use your winnings to enter the next round

# RockPaperScissors test project

You will create a smart contract named `RockPaperScissors` whereby:  
Alice and Bob can play the classic game of rock, paper, scissors using ERC20 (of your choosing).

- To enroll, each player needs to deposit the right token amount, possibly zero. (DONE)
- To play, each Bob and Alice need to submit their unique move. (DONE)
- The contract decides and rewards the winner with all token wagered. (DONE)

There are many ways to implement this, so we leave that up to you.

## Stretch Goals

Nice to have, but not necessary.

- Make it a utility whereby any 2 people can decide to play against each other. (DONE)
- Reduce gas costs as much as possible. (Attempted)
- Let players bet their previous winnings. (DONE)
- How can you entice players to play, knowing that they may have their funds stuck in the contract if they face an uncooperative player? (DONE)
- Include any tests using Hardhat. (DONE)

Now fork this repo and do it!

When you're done, please send an email to zak@slingshot.finance (if you're not applying through Homerun) with a link to your fork or join the [Slingshot Discord channel](https://discord.gg/JNUnqYjwmV) and let us know.

Happy hacking!
