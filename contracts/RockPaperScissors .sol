// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    ADD NATSPEC
 */

contract RockPaperScissors {

    enum Moves{ ROCK, PAPER, SCISSORS, NOT_CHOSEN }
    struct playerMoveStruct {
        bool payed;
        Moves move;
        bool inGame;
        uint256 paid;
    }

    struct customGame {
        address payable playerOne;
        address payable playerTwo;
        Moves playerOneMove;
        Moves playerTwoMove;
    }

    mapping(address => playerMoveStruct) playerMoves;
    mapping(address => customGame) customGames;

    address payable playerOne = payable(address(0));
    address payable playerTwo = payable(address(0));
    string public winner;
    address payable winnerAddress;


    constructor()
    {}

    function getBalance () public view returns (uint256) {
        return address(this).balance;
    }

    function enterNextRound(uint amount) payable public {
        require(msg.value == amount, "Amount is not equal to funds sent");
        require(playerMoves[msg.sender].payed == false, "Already in next round");
        playerMoves[msg.sender] = playerMoveStruct(true, Moves.NOT_CHOSEN, false, msg.value);
    }

    function withdrawWager() public payable {
        payable(msg.sender).transfer(playerMoves[msg.sender].paid);
        delete playerMoves[msg.sender];
    }

    function chooseRock() public {
        require(playerMoves[msg.sender].payed == true, "Player has not payed for next round");
        require(playerMoves[msg.sender].inGame == false, "Player is already in game");
        setMove(Moves.ROCK);
    }

    function choosePaper() public {
        require(playerMoves[msg.sender].payed == true, "Player has not payed for next round");
        require(playerMoves[msg.sender].inGame == false, "Already in game");
        setMove(Moves.PAPER);
    }

    function chooseScissors() public {
        require(playerMoves[msg.sender].payed == true, "Player has not payed for next round");
        require(playerMoves[msg.sender].inGame == false, "Already in game");
        setMove(Moves.SCISSORS);
    }

    function chooseRockAgainst(address oponent) public {
        //Check if bothj players hasve paid
        require(playerMoves[msg.sender].payed == true, "Player has not payed for next round");
        require(playerMoves[oponent].payed == true, "Opponent has not payed for next round");

        //Check if you and opponent are free to play
        require(playerMoves[msg.sender].inGame == false, "You are already in game");
        require(playerMoves[opponent].inGame == false, "Opponent is already in game");

        require(customGames[msg.sender].playerTwo == address(0), "You are already in a custom game");
        // require(customGames[oponent].playerTwo == address(0), "Opponent is already in a custom game");

        //If custom game has not been setup yet, create it and set move
        if(customGames[msg.sender].playerOne == address(0) && customGames[oponent].playerOne == address(0)){
            customGame newGame = customGame(msg.sender, oponent, Moves.ROCK, Moves.NOT_CHOSEN);
            customGames[msg.sender] = newGame;
            customGames[oponent] = newGame;
        } else {
            customGames[msg.sender].playerTwoMove = Moves.ROCK;

            //Find winner
        }

        //Check if both players have made their move
    }

    function setMove(Moves _move) internal {
        //Check if game already has 2 players
        require(playerOne == address(0) || playerTwo == address(0), "A game is currently already in progress");
        
        //Assiging move
        if(playerOne == address(0)){
            playerOne = payable(msg.sender);
            playerMoves[msg.sender].move = _move;
            playerMoves[msg.sender].inGame = true;
        }
        else if (playerTwo == address(0))  {
            playerTwo = payable(msg.sender);
            playerMoves[msg.sender].move = _move;
            playerMoves[msg.sender].inGame = true;
        }

        if(playerOne != address(0) && playerTwo != address(0)){
            findWinner();
        }
    }

    function findWinner() internal {
        if(playerMoves[playerOne].move == Moves.PAPER){
            if(playerMoves[playerTwo].move == Moves.PAPER){
                //I dont know
            } 
            else if (playerMoves[playerTwo].move == Moves.ROCK){
                winner = "WINNER = Player One";
                winnerAddress = playerOne;
            }
            else if (playerMoves[playerTwo].move == Moves.SCISSORS){
                winner = "WINNER = Player Two";
                winnerAddress = playerTwo;
            }
        }
        else if(playerMoves[playerOne].move == Moves.ROCK){
            if(playerMoves[playerTwo].move == Moves.PAPER){
                winner = "WINNER = Player Two";
                winnerAddress = playerTwo;
            } 
            else if (playerMoves[playerTwo].move == Moves.ROCK){
            
            }
            else if (playerMoves[playerTwo].move == Moves.SCISSORS){
                winnerAddress = playerOne;
                winner = "WINNER = Player One";
            }
        }
        else if (playerMoves[playerOne].move == Moves.SCISSORS){
            if(playerMoves[playerTwo].move == Moves.PAPER){
                winnerAddress = playerOne;
                winner = "WINNER = Player One";
            } 
            else if (playerMoves[playerTwo].move == Moves.ROCK){
                winnerAddress = playerTwo;
                winner = "WINNER = Player Two";
            }
            else if (playerMoves[playerTwo].move == Moves.SCISSORS){
                
            }
        }

        if(winnerAddress != address(0)){
            sendWinnings();
        }
    }
    
    function sendWinnings() internal {
        winnerAddress.transfer(address(this).balance);
        clearPlayerData();
    }

    function clearPlayerData() internal {
        winnerAddress = payable(address(0));
        delete playerMoves[playerOne];
        delete playerMoves[playerTwo];
        playerOne = payable(address(0));
        playerTwo = payable(address(0));
    }
}