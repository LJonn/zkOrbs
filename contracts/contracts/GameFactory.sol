//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./GameInstance.sol";

contract GameFactory {
    //constructor to set owner for some functions?
    GameInstance[] gameInstances;

    //event InstanceCreated(address instance);

    function createGameInstance(address _player1) public {
        //returns (address) {
        GameInstance gameInstance = new GameInstance(_player1);
        gameInstances.push(gameInstance);
        //return address(gameInstance);
    }

    function getActive() public view returns (address[] memory) {
        //TODO change to check for player2 init //getActiveInstances
        uint256 counter = 0;
        for (uint256 i = 0; i < gameInstances.length; ) {
            GameInstance instance = GameInstance(address(gameInstances[i]));
            if (instance.isActive()) {
                ++counter;
            }
            unchecked {
                ++i;
            }
        }
        address[] memory activeInstances = new address[](counter);
        uint256 j = 0;
        for (uint256 i = 0; i < gameInstances.length; ) {
            GameInstance instance = GameInstance(address(gameInstances[i]));
            if (instance.isActive()) {
                activeInstances[j] = address(instance);
                ++j;
            }
            unchecked {
                ++i;
            }
        }
        return activeInstances;
    }
}
