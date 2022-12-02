pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomWinnerGame is VRFConsumerBase, Ownable {
    uint256 public fee; // Taken in LINK
    // ID of public key against which randomness is generated
    bytes32 public keyHash;

    address[] public players;
    uint8 maxPlayers;

    bool public gameStarted;
    uint256 entryFee;

    uint256 public gameId;

    event GameStarted(uint256 gameId, uint8 maxPlayers, uint256 entryFee);
    event PlayerJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, address winner, bytes32 requestedId);

    constructor(
        address vrfCoordinator, address linkToken,
        bytes32 vrfKeyHash, uint256 vrfFee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

    function startGame(uint8 _maxPlayers, uint256 _entryFee) public onlyOwner {
        require(!gameStarted, "Game is currently in process");
        delete players;
        maxPlayers = _maxPlayers;
        gameStarted = true;
        entryFee = _entryFee;
        gameId += 1;
        emit GameStarted(gameId, maxPlayers, entryFee);
    }

    function joinGame() public payable {
        require(gameStarted, "Game has not started");
        require(msg.value == entryFee, "Value sent is not equal to entry fee");
        require(players.length < maxPlayers, "Game is full");

        players.push(msg.sender);
        emit PlayerJoined(msg.sender);

        if (players.length == maxPlayers) {
            getRandomWinner();
        }
    }


    function fulfillRandomness(bytes32 requestedId, uint256 randomness) internal virtual override {
        uint256 winnerIndex = randomness % players.length;
        address winner = players[winnerIndex];
        (bool sent,) = winner.call{value : address(this).balance}("");
        require(sent, "Failed to send Ether");
        emit GameEnded(gameId, winner, requestedId);
        gameStarted = false;
    }

    function getRandomWinner() private returns (bytes requestedId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        return requestRandomness(keyHash, fee);
    }

    receive() external payable {}

    fallback() external payable {}
}
