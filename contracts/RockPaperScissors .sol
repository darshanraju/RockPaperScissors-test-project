// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

/**
    ADD NATSPEC
 */

contract RockPaperScissors {

    enum Moves{ ROCK, PAPER, SCISSORS, NOT_CHOSEN }
    enum GameModes{ GLOBAL, CUSTOM, NONE }

    struct paidStruct {
        bool paid;
        uint256 waged;
        GameModes GameMode;
    }

    struct customGame {
        address payable playerOne;
        address payable playerTwo;
        Moves playerOneMove;
        Moves playerTwoMove;
    }

    mapping(address => address) customGamePlayers;
    mapping(address => paidStruct) players;
    mapping(address => customGame) public customGames;

    address payable playerOne = payable(address(0));
    address payable playerTwo = payable(address(0));
    
    Moves public playerOneMove = Moves.NOT_CHOSEN;
    Moves public playerTwoMove = Moves.NOT_CHOSEN;

    address payable winnerAddress;

    constructor()
    {}

    function getBalance () public view returns (uint256) {
        return address(this).balance;
    }

    function enterNextRound(uint amount) payable public {

        console.log("Recieving Value: %s", msg.value);
        console.log("Amount said: %s", amount);

        require(msg.value == amount, "Amount is not equal to funds sent");
        require(players[msg.sender].paid == false, "Already paid");
        players[msg.sender] = paidStruct(true, msg.value, GameModes.NONE);
    }

    function withdrawWager() public payable {
        require(players[msg.sender].waged > 0, "No funds to withdraw");
        payable(msg.sender).transfer(players[msg.sender].waged);
        delete players[msg.sender];
    }

    function chooseRock() public {
        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        setMove(Moves.ROCK);
    }

    function chooseRockAgainst(address opponent) public {

        console.log("ROCK opponent: ", opponent);


        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        require(players[opponent].paid == true, "opponent has not payed for next round");
        require(customGamePlayers[opponent] == address(0) || customGamePlayers[opponent] == msg.sender, "Opponent is already in custome game with other player");
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.ROCK, opponent);
    }

    function choosePaper() public {
        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        setMove(Moves.PAPER);
    }

    function choosePaperAgainst(address opponent) public {
        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        require(players[opponent].paid == true, "opponent has not payed for next round");
        require(customGamePlayers[opponent] == address(0) || customGamePlayers[opponent] == msg.sender, "Opponent is already in custome game with other player");
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.PAPER, opponent);
    }

    function chooseScissors() public {
        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        setMove(Moves.SCISSORS);
    }

    function chooseScissorsAgainst(address opponent) public {

        console.log("Scissors opponent: ", opponent);

        require(players[msg.sender].paid == true, "Player has not payed for next round");
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        require(players[opponent].paid == true, "opponent has not payed for next round");
        require(customGamePlayers[opponent] == address(0) || customGamePlayers[opponent] == msg.sender, "Opponent is already in custome game with other player");
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.SCISSORS, opponent);
    }

    function setMove(Moves _move) internal {
        //Check if global game already has 2 players (turn into modifier)
        require(playerOne == address(0) || playerTwo == address(0), "A global game is currently already in progress");
        players[msg.sender].GameMode = GameModes.GLOBAL;

        //Assiging move
        if(playerOne == address(0)){
            playerOne = payable(msg.sender);
            playerOneMove = _move;
        }
        else if (playerTwo == address(0))  {
            playerTwo = payable(msg.sender);
            playerTwoMove = _move;
        }

        if(playerOne != address(0) && playerTwo != address(0)){
            winnerAddress = payable(findWinner(playerOneMove, playerTwoMove, playerOne, playerTwo));
            console.log("winner: ", winnerAddress);
            sendGlobalWinnings(winnerAddress);
        }
    }

    function setCustomMove(Moves _move, address opponent) internal {
        players[msg.sender].GameMode == GameModes.CUSTOM;

        //Create new custom game between players if not already created
        if(customGamePlayers[opponent] == address(0)){
            console.log("Creating new game: ", msg.sender);
            customGame memory newGame = customGame(payable(msg.sender), payable(opponent), _move, Moves.NOT_CHOSEN);
            customGames[msg.sender] = newGame;
            customGames[opponent] = newGame;
        }
        //Add move to game if already created by opponent
        else{
            console.log("Need to find winner");
            customGames[msg.sender].playerTwoMove = _move;
                        console.log("player 1: ",opponent );
            console.log("player 2: ",msg.sender );
            address payable winner = payable(findWinner(customGames[msg.sender].playerTwoMove, customGames[opponent].playerOneMove, msg.sender, opponent));

            console.log("Winner: ", winner);
            sendCustomerWinnings(winner);
        }
    }

    function findWinner(Moves _move1, Moves _move2, address _player1, address _player2) internal returns (address) {
        if(_move1 == Moves.PAPER){
            if(_move2 == Moves.PAPER){
                return address(0);
            } 
            else if (_move2 == Moves.ROCK){
                winnerAddress = playerOne;
                return _player1;
            }
            else if (_move2 == Moves.SCISSORS){
                winnerAddress = playerTwo;
                return _player2;
            }
        }
        else if(_move1 == Moves.ROCK){
            if(_move2 == Moves.PAPER){
                winnerAddress = playerTwo;
                return _player2;
            } 
            else if (_move2 == Moves.ROCK){
                return address(0);
            }
            else if (_move2 == Moves.SCISSORS){
                winnerAddress = playerOne;
                return _player1;
            }
        }
        else if (_move1 == Moves.SCISSORS){
            console.log("scissors move");
            if(_move2 == Moves.PAPER){
                                                console.log("ROCK PAPA ");

                winnerAddress = playerOne;
                return _player1;
            } 
            else if (_move2 == Moves.ROCK){
                console.log("ROCK MOVE ");
                winnerAddress = playerTwo;
                return _player2;
            }
            else if (_move2 == Moves.SCISSORS){
                                console.log("ROCK SCISSOR ");

                return address(0);
            }
        }
        console.log("NO MATCH");
        return address(0);
    }
    
    function sendCustomerWinnings(address payable _winner) internal {

        address _loser = customGamePlayers[_winner];

        _winner.transfer(players[_winner].waged+players[_loser].waged);

        delete players[_winner];
        delete players[_loser];

        delete customGamePlayers[_winner];
        delete customGamePlayers[_loser];

        delete customGames[_winner];
        delete customGames[_loser];
    }

    function sendGlobalWinnings(address payable _winner) internal {

        console.log("Winner is: ", _winner);
        console.log("Sending: ", players[playerOne].waged + players[playerTwo].waged);

        _winner.transfer(players[playerOne].waged + players[playerTwo].waged);
        clearGlobalPlayerData();
    }

    function clearGlobalPlayerData() internal {
        delete players[playerOne];
        delete players[playerTwo];
        playerOne = payable(address(0));
        playerTwo = payable(address(0));
    }

    function getWinningsBalance() public returns (uint256) {
        //From global game?
    }
}