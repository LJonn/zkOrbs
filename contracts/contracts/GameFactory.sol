//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./GameInstance.sol";
contract GameFactory{
//constructor to set owner for some functions?
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
            _player1,
            _player2,
            _map
        );
        gameInstances.push(gameInstance);
        emit InstanceCreated(address(gameInstance));
    }

    function getActive() view public returns (address[] memory) {
        uint counter=0;
        for (uint i=0; i<gameInstances.length;){
            GameInstance instance=GameInstance(address(gameInstances[i]));
            if (instance.isActive()){
                ++counter;
            }
            unchecked { ++i; }
        }
        address[] memory activeInstances = new address[](counter);
        uint j=0;
        for (uint i=0; i<gameInstances.length;){
            GameInstance instance=GameInstance(address(gameInstances[i]));
            if (instance.isActive()){
                activeInstances[j]=address(instance);
                ++j;
            }
            unchecked { ++i; }
        }
        return activeInstances;
    }
}