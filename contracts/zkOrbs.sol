//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract zkOrbs{
//Work in progress, this is not functional yet

    // event ContractAddress(address addr);

    // function emitContractAddress() public{
    //     emit ContractAddress(address(this));
    // }

    constructor(string memory _name, address _owner, uint8[10][10] memory _map){
        name=_name;
        owner=msg.sender;
        map=_map;
    }

    string public name;
    address public owner;

    uint8[10][10] public map;

//STAGES----------------------/
    enum Stages {
        INIT,
        SET_P2,
        SPAWN_P1,
        SPAWN_P2,
        TURN_P1,
        TURN_P2
    }

    modifier atStage(Stages _stage) {
            require(
                stage == _stage,
                "Wrong pooling stage. Action not allowed."
            );
            _;
    }
//----------------------STAGES/


    struct coordinates{
        uint8 x;
        uint8 y;
    }
    
    Stages public stage = Stages.INIT;

    function createGame(bool _customMap) external{

        // if (_customMap){
        //     stage = Stages.SET_MAP;
        // }
        // else{
        //     stage = Stages.SET_P2;
        // }
    }
//func setMap stage initializeMap
//func spawnPlayer1 stage player1
//func spawnPlayer2 stage player2
}

/*SET map example:
    [[1,0,0,0,0,0,0,0,0,0],
    [0,0,0,2,2,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [1,1,1,0,0,0,1,1,1,1],
    [1,0,0,0,0,0,1,0,0,3],
    [3,0,0,1,0,0,0,0,0,1],
    [1,1,1,1,0,0,0,1,1,1],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,0],
    [0,0,0,0,0,0,0,0,0,1]]
*/

