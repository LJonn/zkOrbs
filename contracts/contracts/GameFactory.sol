//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./GameInstance.sol";
contract GameFactory{

    GameInstance[] gameInstances;
    event InstanceCreated(address instance);
    function createGameInstance(
        string memory _instanceName,
        address _player1,
        address _player2, //send address(0) for others to join
        uint8[10][10] memory _map) public
    {
        GameInstance gameInstance = new GameInstance(
            _instanceName,
            msg.sender,
            _player2,
            _map
        );
        gameInstances.push(gameInstance);
        emit InstanceCreated(address(gameInstance));
    }
}