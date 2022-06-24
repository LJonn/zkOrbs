//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract GameInstance{
//Work in progress, this is not functioning properly yet

    // event ContractAddress(address addr);

    // function emitContractAddress() public{
    //     emit ContractAddress(address(this));
    // }
    struct mapField{
        uint8 fieldType; //0-walkable//1-unwalkable//2-movable//3-station//
        address fieldOwner;
    }

    string public instanceName;
    address public player1;
    address public player2;
    mapField[10][10] public map;
    bool active;


    constructor(
        string memory _instanceName,
        address _player1,
        address _player2,
        uint8[10][10] memory _map
    ){
        instanceName=_instanceName;
        player1=_player1;
        player2=_player2;
        for (uint8 i=0; i<10;){
            for (uint8 u=0; u<10;){
                map[i][u].fieldType=_map[i][u];
                map[i][u].fieldOwner=address(0);
                unchecked { ++u; }
            }
            unchecked { ++i; }
        }
        active = true;
    }

    function isActive() view public returns (bool){
        return active;
    }
}
// //STAGES----------------------/
//     enum Stages {
//         INIT,
//         SET_P2,
//         SPAWN_P1,
//         SPAWN_P2,
//         TURN_P1,
//         TURN_P2
//     }

//     modifier atStage(Stages _stage) {
//             require(
//                 stage == _stage,
//                 "Wrong pooling stage. Action not allowed."
//             );
//             _;
//     }
// //----------------------STAGES/



    
//     Stages public stage = Stages.INIT;

//     function createGame(bool _customMap) external{

//         // if (_customMap){
//         //     stage = Stages.SET_MAP;
//         // }
//         // else{
//         //     stage = Stages.SET_P2;
//         // }
//     }
// //func setMap stage initializeMap
// //func spawnPlayer1 stage player1
// //func spawnPlayer2 stage player2
// }

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

