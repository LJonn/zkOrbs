//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IInitVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) external view returns (bool r);
}

interface IAttackOrbVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) external view returns (bool r);
}

interface IDefendOrbVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[5] memory input
    ) external view returns (bool r);
}

interface IAttackerEResaltVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) external view returns (bool r);
}

contract GameInstance {
    // event ContractAddress(address addr);

    // function emitContractAddress() public{
    //     emit ContractAddress(address(this));
    // }
    struct mapField {
        uint8 fieldType; //0-walkable//1-unwalkable//2-movable//3-station//
        address fieldOwner;
    }

    address public player1;
    address public player2;
    uint256 p1EnergyH;
    uint256 p2EnergyH;
    uint8 energyMemory;
    uint8 attackRow;
    uint8 attackColumn;
    uint8 defendRow;
    uint8 defendColumn;

    mapField[10][10] public map;
    bool active;
    //STAGES----------------------/
    enum Stages {
        SET_P2,
        SPAWN_P1,
        SPAWN_P2,
        TURN_P1,
        TURN_P2,
        ATTACK_P1,
        ATTACK_P2,
        DEFEND_P1,
        DEFEND_P2,
        OUTCOME_P1,
        OUTCOME_P2,
        THE_END
    }
    Stages public stage;
    modifier atStage(Stages _stage) {
        require(stage == _stage, "Wrong stage. Action not allowed.");
        _;
    }

    //----------------------STAGES/

    constructor(address _player1) {
        uint8[10][10] memory _map = [
            [1, 1, 1, 0, 0, 0, 0, 3, 3, 1],
            [1, 0, 3, 0, 3, 0, 0, 0, 0, 3],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
            [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
            [3, 0, 0, 1, 0, 0, 0, 0, 0, 1],
            [1, 1, 1, 1, 0, 0, 0, 1, 1, 1],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [1, 3, 1, 1, 1, 1, 0, 0, 1, 3]
        ];
        player1 = _player1;
        for (uint8 i = 0; i < 10; ) {
            for (uint8 u = 0; u < 10; ) {
                map[i][u].fieldType = _map[i][u];
                unchecked {
                    ++u;
                }
            }
            unchecked {
                ++i;
            }
        }
        active = true;
        stage = Stages.SET_P2;
    }

    function setPlayer2() public atStage(Stages.SET_P2) {
        require(
            msg.sender != player1,
            "player2 must have a different address than player1"
        );
        player2 = msg.sender;
        stage = Stages.SPAWN_P1;
        active = false;
    }

    function setSpawn(
        uint8 row,
        uint8 column,
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public {
        if (stage == Stages.SPAWN_P1) {
            require(msg.sender == player1, "only player1 can set his position");
        } else if (stage == Stages.SPAWN_P2) {
            require(msg.sender == player2, "only player2 can set his position");
        } else {
            revert("wrong stage");
        }
        require(map[row][column].fieldType == 3, "field is not a station");
        require(
            map[row][column].fieldOwner == address(0),
            "station already taken"
        );
        map[row][column].fieldType = 2;
        map[row][column].fieldOwner = msg.sender;
        require(vInit(_address, a, b, c, input));
        if (stage == Stages.SPAWN_P1) {
            p1EnergyH = input[0];
            stage = Stages.SPAWN_P2;
        } else if (stage == Stages.SPAWN_P2) {
            p2EnergyH = input[0];
            stage = Stages.TURN_P1;
        }
    }

    function moveOrb(
        uint8 row,
        uint8 column,
        uint8 direction
    ) public {
        require(
            column >= 0 && column <= 9 && row >= 0 && row <= 9,
            "coordinates outside map bounds"
        );
        require(map[row][column].fieldType == 2, "field is not an orb");
        if (stage == Stages.TURN_P1) {
            require(msg.sender == player1, "player1 turn");
            require(
                map[row][column].fieldOwner == player1,
                "you can't move player1 orb"
            );
        } else if (stage == Stages.TURN_P2) {
            require(msg.sender == player2, "player2 turn");
            require(
                map[row][column].fieldOwner == player2,
                "you can't move player2 orb"
            );
        }
        uint8 newRow = row;
        uint8 newColumn = column;
        if (direction == 0) {
            //UP
            newRow = row - 1;
        } else if (direction == 1) {
            //RIGHT
            newColumn = column + 1;
        } else if (direction == 2) {
            //DOWN
            newRow = row + 1;
        } else if (direction == 3) {
            //LEFT
            newColumn = column - 1;
        }
        require(
            newColumn >= 0 && newColumn <= 9 && newRow >= 0 && newRow <= 9,
            "can't move outside map"
        );
        if (map[newRow][newColumn].fieldType == 2) {
            if (stage == Stages.TURN_P1) {
                stage = Stages.ATTACK_P1;
            } else if (stage == Stages.TURN_P2) {
                stage = Stages.ATTACK_P2;
            }
            attackRow = row;
            attackColumn = column;
            defendRow = newRow;
            defendColumn = newColumn;
        } else {
            require(
                map[newRow][newColumn].fieldType == 0,
                "can't move to non empty field"
            );

            map[row][column].fieldType = 0;
            map[row][column].fieldOwner = address(0);
            map[newRow][newColumn].fieldType = 2;
            if (stage == Stages.TURN_P1) {
                map[newRow][newColumn].fieldOwner = player1;
                stage = Stages.TURN_P2;
            } else if (stage == Stages.TURN_P2) {
                map[newRow][newColumn].fieldOwner = player2;
                stage = Stages.TURN_P1;
            }
        }
    }

    function attackOrb(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public {
        // input[0] = attackHashCheck Out
        // input[1] = attackEnergy In
        require(stage == Stages.ATTACK_P1 || stage == Stages.ATTACK_P2);
        if (stage == Stages.ATTACK_P1) {
            require(player1 == msg.sender);
            require(p1EnergyH == input[0]);
            stage = Stages.DEFEND_P2;
        } else {
            require(player2 == msg.sender);
            require(p2EnergyH == input[0]);
            stage = Stages.DEFEND_P1;
        }
        energyMemory = uint8(input[1]);
        require(vAttack(_address, a, b, c, input));
    }

    function defendOrb(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[5] memory input
    ) public {
        require(stage == Stages.DEFEND_P1 || stage == Stages.DEFEND_P2);
        if (stage == Stages.DEFEND_P1) {
            require(player1 == msg.sender);
            stage = Stages.OUTCOME_P2;
        } else {
            require(player2 == msg.sender);
            stage = Stages.OUTCOME_P1;
        }

        require(
            uint8(input[4]) == energyMemory,
            "attack energies on chain and in callback should be equal"
        );
        require(p1EnergyH == input[1], "hash check");
        energyMemory = uint8(input[0]); //attacker energy left
        p1EnergyH = input[2];
        if (input[3] == 1) {
            map[defendRow][defendColumn].fieldType = 0;
            map[defendRow][defendColumn].fieldOwner = address(0);
        }
        require(vDefend(_address, a, b, c, input), "defend proof failed");
    }

    function setOutcome(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public {
        require(
            stage == Stages.OUTCOME_P1 || stage == Stages.OUTCOME_P2,
            "wrong stage"
        );
        require(energyMemory == input[1]);
        if (stage == Stages.OUTCOME_P1) {
            require(player1 == msg.sender, "should've been player1");
        } else {
            require(player2 == msg.sender, "should've been player2");
        }
        if (energyMemory != 0) {
            map[defendRow][defendColumn].fieldType = 2;
            map[defendRow][defendColumn].fieldOwner = address(msg.sender);
        }
        map[attackRow][attackColumn].fieldType = 0;
        map[attackRow][attackColumn].fieldOwner = address(0);
        require(vResalt(_address, a, b, c, input));
        stage = Stages.THE_END;
    }

    function getGameStage() public view returns (uint8) {
        return uint8(stage);
    }

    function getMap() public view returns (mapField[10][10] memory) {
        return map;
    }

    function getEnergyMemory() public view returns (uint8) {
        return energyMemory;
    }

    function isActive() public view returns (bool) {
        return active;
    }

    function vInit(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool isOk) {
        isOk = IInitVerifier(_address).verifyProof(a, b, c, input);
    }

    function vAttack(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool isOk) {
        isOk = IAttackOrbVerifier(_address).verifyProof(a, b, c, input);
    }

    function vDefend(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[5] memory input
    ) public view returns (bool isOk) {
        isOk = IDefendOrbVerifier(_address).verifyProof(a, b, c, input);
    }

    function vResalt(
        address _address,
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool isOk) {
        isOk = IAttackerEResaltVerifier(_address).verifyProof(a, b, c, input);
    }
}
