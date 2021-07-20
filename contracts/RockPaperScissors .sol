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
    mapping(address => customGame) customGames;
    mapping(address => uint256) winnings;

    address payable playerOne = payable(address(0));
    address payable playerTwo = payable(address(0));
    
    Moves public playerOneMove = Moves.NOT_CHOSEN;
    Moves public playerTwoMove = Moves.NOT_CHOSEN;

    address payable winnerAddress;

    constructor()
    {}

    modifier PayedPlayer() {
        require(players[msg.sender].paid == true, "Player has not payed for next round");
        _;
    }   

    modifier PlayerInGame() {
        require(players[msg.sender].GameMode == GameModes.NONE, "Player is already in game");
        _;
    }   

    modifier OpponentPaid(address opponent) {
        require(players[opponent].paid == true, "opponent has not payed for next round");
        _;
    }   

    modifier OpponentInGame(address opponent) {
        require(customGamePlayers[opponent] == address(0) || customGamePlayers[opponent] == msg.sender, "Opponent is already in custom game with other player");
        _;
    }

    function getBalance () public view returns (uint256) {
        return address(this).balance;
    }

    function enterNextRound(uint amount) payable public {
        require(msg.value == amount, "Amount is not equal to funds sent");
        require(players[msg.sender].paid == false, "Already paid");
        players[msg.sender] = paidStruct(true, msg.value, GameModes.NONE);
    }

    function betWinnings() public {
        require(winnings[msg.sender] > 0, "You have no winnings to bet with");
        players[msg.sender] = paidStruct(true, winnings[msg.sender], GameModes.NONE);
        winnings[msg.sender] = 0;
    }

    function withdrawWager() public payable {
        require(players[msg.sender].waged > 0, "No funds to withdraw");
        payable(msg.sender).transfer(players[msg.sender].waged);
        delete players[msg.sender];
    }

    function chooseRock() public PayedPlayer PlayerInGame {
        setMove(Moves.ROCK);
    }

    function chooseRockAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent) OpponentInGame(opponent) {
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.ROCK, opponent);
    }

    function choosePaper() public PayedPlayer PlayerInGame{
        setMove(Moves.PAPER);
    }

    function choosePaperAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent)  OpponentInGame(opponent) {
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.PAPER, opponent);
    }

    function chooseScissors() public PayedPlayer PlayerInGame{
        setMove(Moves.SCISSORS);
    }

    function chooseScissorsAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent)  OpponentInGame(opponent) {
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
            if(winnerAddress == address(0)){
                //Draw
                players[playerOne].GameMode = GameModes.NONE;
                players[playerTwo].GameMode = GameModes.NONE;

                playerOne = payable(address(0));
                playerTwo = payable(address(0));
            } else {
                setGlobalWinnings(winnerAddress);
                clearGlobalPlayerData();
            }
        }
    }

    function setCustomMove(Moves _move, address opponent) internal {
        players[msg.sender].GameMode == GameModes.CUSTOM;

        //Create new custom game between players if opponent hasn't already started a game against you
        if(customGamePlayers[opponent] == address(0)){
            customGame memory newGame = customGame(payable(msg.sender), payable(opponent), _move, Moves.NOT_CHOSEN);
            customGames[msg.sender] = newGame;
            customGames[opponent] = newGame;
        }
        //Add move to game if already created by opponent
        else{
            customGames[msg.sender].playerTwoMove = _move;
            address payable winner = payable(findWinner(customGames[msg.sender].playerTwoMove, customGames[opponent].playerOneMove, msg.sender, opponent));
            if(winner == address(0)){
                //Draw
                delete customGames[msg.sender];
                delete customGames[opponent];

                delete customGamePlayers[msg.sender];
                delete customGamePlayers[opponent];

                players[msg.sender].GameMode = GameModes.NONE;
                players[opponent].GameMode = GameModes.NONE;
            } else {
                setCustomerWinnings(winner);
                clearCustomGamePlayerData(msg.sender, opponent);
            }
        }
    }

    function findWinner(Moves _move1, Moves _move2, address _player1, address _player2) pure internal returns (address) {
        if(_move1 == Moves.PAPER){
            if(_move2 == Moves.PAPER){
                return address(0);
            } 
            else if (_move2 == Moves.ROCK){
                return _player1;
            }
            else if (_move2 == Moves.SCISSORS){
                return _player2;
            }
        }
        else if(_move1 == Moves.ROCK){
            if(_move2 == Moves.PAPER){
                return _player2;
            } 
            else if (_move2 == Moves.ROCK){
                return address(0);
            }
            else if (_move2 == Moves.SCISSORS){
                return _player1;
            }
        }
        else if (_move1 == Moves.SCISSORS){
            if(_move2 == Moves.PAPER) {
                return _player1;
            } 
            else if (_move2 == Moves.ROCK){
                return _player2;
            }
            else if (_move2 == Moves.SCISSORS){
                return address(0);
            }
        }
        return address(0);
    }
    
    function setCustomerWinnings(address payable _winner) internal {
        address _loser = customGamePlayers[_winner];
        winnings[_winner] += players[_winner].waged+players[_loser].waged;
    }

    function setGlobalWinnings(address payable _winner) internal {
        winnings[_winner] += players[playerOne].waged + players[playerTwo].waged;
    }

    function clearCustomGamePlayerData(address _player1, address _player2) internal {
        delete players[_player1];
        delete players[_player2];

        delete customGamePlayers[_player1];
        delete customGamePlayers[_player2];

        delete customGames[_player1];
        delete customGames[_player2];
    }

    function clearGlobalPlayerData() internal {
        delete players[playerOne];
        delete players[playerTwo];
        playerOne = payable(address(0));
        playerTwo = payable(address(0));
    }

    function getWinnings() public {
        require(winnings[msg.sender] > 0, "You have no winnings. LOL");
        payable(msg.sender).transfer(winnings[msg.sender]);
        winnings[msg.sender] = 0;
    }
}