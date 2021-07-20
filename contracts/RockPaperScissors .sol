// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A contract that allows people to play rock, paper, scissors, against randomly chosen player or specific players
///        There are types of games played, a Global game where any 2 random players can pick a move and are put against each other,
///        and a Custom game, 
/// @author Darshan Raju
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

    /// @notice Checks current funds held within contract, (mainly used for in unit tests)
    /// @return Returns funds held in contract as uint256
    function getBalance () public view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Enable players to send funds to enter a the next rock, paper, scissors round
    /// @param amount is the funds being sent
    /// @dev add a mapping value to track that the player has paid, the amount they paid, and their move
    function enterNextRound(uint amount) payable public {
        require(msg.value == amount, "Amount is not equal to funds sent");
        require(players[msg.sender].paid == false, "Already paid");
        players[msg.sender] = paidStruct(true, msg.value, GameModes.NONE);
    }

    /// @notice ALlow players to bet their current winnings to enter the next round
    function betWinnings() public {
        require(winnings[msg.sender] > 0, "You have no winnings to bet with");
        players[msg.sender] = paidStruct(true, winnings[msg.sender], GameModes.NONE);
        winnings[msg.sender] = 0;
    }

    /// @notice Allow players to withdraw their funds held in contract if they choose to not play
    function withdrawWager() public payable {
        require(players[msg.sender].waged > 0, "No funds to withdraw");
        payable(msg.sender).transfer(players[msg.sender].waged);
        delete players[msg.sender];
    }

    /// @notice Choose rock against a random player in the global match
    function chooseRock() public PayedPlayer PlayerInGame {
        setMove(Moves.ROCK);
    }

    /// @notice Choose rock against a specific player in a custom match
    function chooseRockAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent) OpponentInGame(opponent) {
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.ROCK, opponent);
    }

    /// @notice Choose paper against a random player in the global match
    function choosePaper() public PayedPlayer PlayerInGame{
        setMove(Moves.PAPER);
    }

    /// @notice Choose paper against a specific player in a custom match
    function choosePaperAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent)  OpponentInGame(opponent) {
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.PAPER, opponent);
    }

    /// @notice Choose scissors against a random player in the global match
    function chooseScissors() public PayedPlayer PlayerInGame{
        setMove(Moves.SCISSORS);
    }

    /// @notice Choose scissors against a specific player in a custom match
    function chooseScissorsAgainst(address opponent) public PayedPlayer PlayerInGame OpponentPaid(opponent)  OpponentInGame(opponent) {
        customGamePlayers[msg.sender] = opponent;
        setCustomMove(Moves.SCISSORS, opponent);
    }

    /// @notice Common function called by all global game move functions (chooseRock, etc.)
    /// @dev Set the move of the player in the players mapping
    /// @param _move takes a value of the Moves enum
    function setMove(Moves _move) internal {
        //Check if a global game already has 2 players
        require(playerOne == address(0) || playerTwo == address(0), "A global game is currently already in progress");
        players[msg.sender].GameMode = GameModes.GLOBAL;

        //Assiging move as player1 or player2
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
                //Draw, clear moves and global player addresses
                players[playerOne].GameMode = GameModes.NONE;
                players[playerTwo].GameMode = GameModes.NONE;

                playerOne = payable(address(0));
                playerTwo = payable(address(0));
            } else {
                //Assign funds to winner and clear global player data
                setGlobalWinnings(winnerAddress);
                clearGlobalPlayerData();
            }
        }
    }

    /// @notice Common function called by all custom game move functions (chooseRockAgainst, etc.)
    /// @dev Finds the specific custom game being played in mapping, and updated move
    /// @param _move takes a value of the Moves enum
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
                //Draw, clear custom game, moves and opponent mapping
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

/// @notice Finds the winner given 2 moves and their corresponding move owners
/// @param _move1 move of player1, takes a value of the Moves enum
/// @param _move2 move of player2, takes a value of the Moves enum
/// @param _player1 address of player1
/// @param _player2 address of player2
/// @return The address of the winner, address(0) if draw
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
    
    /// @notice Assigns the winnings of a custom game to the winners address
    /// @param _winner the address of the winner of a custom game
    function setCustomerWinnings(address payable _winner) internal {
        address _loser = customGamePlayers[_winner];
        winnings[_winner] += players[_winner].waged+players[_loser].waged;
    }

    /// @notice Assigns the winnings of a global game to the winners address
    /// @param _winner the address of the winner of the global game
    function setGlobalWinnings(address payable _winner) internal {
        winnings[_winner] += players[playerOne].waged + players[playerTwo].waged;
    }

    /// @notice Clear info of a custom game when finished
    /// @param _player1 Address of player1 in custom game
    /// @param _player2 Address of player2 in custom game
    function clearCustomGamePlayerData(address _player1, address _player2) internal {
        delete players[_player1];
        delete players[_player2];

        delete customGamePlayers[_player1];
        delete customGamePlayers[_player2];

        delete customGames[_player1];
        delete customGames[_player2];
    }

    /// @notice Clear info of a global game when finished
    function clearGlobalPlayerData() internal {
        delete players[playerOne];
        delete players[playerTwo];
        playerOne = payable(address(0));
        playerTwo = payable(address(0));
    }

    /// @notice Withdraw all winnnings
    function getWinnings() public {
        require(winnings[msg.sender] > 0, "You have no winnings. LOL");
        payable(msg.sender).transfer(winnings[msg.sender]);
        winnings[msg.sender] = 0;
    }
}