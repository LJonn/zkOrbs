import Head from "next/head"
import { useRouter } from "next/router";
import { useState, useEffect } from "react";
import { useInterval } from "../utils/useInterval"
import InitVerifierAbi from "../utils/abiFiles/InitVerifier.json";
import GameInstanceAbi from "../utils/abiFiles/GameInstance.json";
import contractAddress from "../utils/contractaddress.json";
import networks from "../utils/networks.json";
import {
    useAccount,
    useNetwork,
    useSigner,
    useProvider,
    useContract,
} from 'wagmi';
import {
    initCallData,
    defendOrbCallData,
    attackOrbCallData,
    attackerEResaltCallData
} from "../zkproof/orbs/snarkjsCalldata";

const STAGES = {
    0: "SET_P2",
    1: "SPAWN_P1",
    2: "SPAWN_P2",
    3: "TURN_P1",
    4: "TURN_P2",
    5: "ATTACK_P1",
    6: "ATTACK_P2",
    7: "DEFEND_P1",
    8: "DEFEND_P2",
    9: "OUTCOME_P1",
    10: "OUTCOME_P2",
    11: "THE_END"
}

function GridBoard() {
    /* next hooks */
    const router = useRouter(); /* comes from index.js activeGameInstances list or if you create a new instance. */
    const gameInstanceAddress = router.query['gameInstanceAddress'];

    return (
        <div>
            {gameInstanceAddress && <PageContent gameInstanceAddress={gameInstanceAddress} />}
        </div>
    )

}

export default GridBoard;

const PageContent = ({ gameInstanceAddress }) => {
    /* wagmi hooks*/
    const { activeChain } = useNetwork();
    const { data: dataAccount } = useAccount();
    const { data: signer } = useSigner();
    const provider = useProvider();


    /* initialise contracts */
    const InitVerifierContract = useContract({
        addressOrName: contractAddress.initVerifierContract,
        contractInterface: InitVerifierAbi.abi,
        signerOrProvider: signer || provider,
    });

    const GameInstanceContract = useContract({
        addressOrName: gameInstanceAddress,
        contractInterface: GameInstanceAbi.abi,
        signerOrProvider: signer || provider,
    });

    /* state hooks */
    const [energy, setEnergy] = useState(0);
    const [currentCell, setCurrentCell] = useState({ column: 0, row: 0 });
    const [gameStage, setGameStage] = useState(1);
    const [grid, setGrid] = useState([[]]);
    const [salt, setSalt] = useState();
    useEffect(() => { setSalt(Math.floor(Math.random() * 999999) + 1) }, []);

    /* hooks on initialisation */
    useEffect(() => {
        async function fetchGrid() {
            const newGrid /* Array<Array<[number, address]>> */ = await GameInstanceContract.getMap();
            setGrid(newGrid);
        };

        async function fetchGameStage() {
            const gameStage /* number */ = await GameInstanceContract.getGameStage();
            setGameStage(gameStage);
        }

        if (GameInstanceContract) {
            fetchGrid();
            fetchGameStage();
        };

    }, []);

    useInterval(async () => {
        if (!GameInstanceContract) return;

        const newGrid /* Array<Array<[number, address]>> */ = await GameInstanceContract.getMap();
        setGrid(newGrid);

        const gameStage /* number */ = await GameInstanceContract.getGameStage();
        setGameStage(gameStage);

    }, 1000 /* interval in ms */);

    /* loading fallback rendering */
    if (!dataAccount || !provider) {
        return (
            <div />
        )
    }

    const playerAddress = dataAccount.address;

    /* helper functions */
    async function setPlayer2() {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;
            const response = await GameInstanceContract.setPlayer2();
            console.log(response);
        }
        catch (error) {
            console.log(error)
        }
    }

    async function handleSpawn() {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;
            const callData = await initCallData(energy, salt);
            if (callData) {
                console.log(currentCell);
                const response = await GameInstanceContract.setSpawn(currentCell.row, currentCell.column, contractAddress.initVerifierContract, callData.a, callData.b, callData.c, callData.Input);
                console.log(response);
            }
        }
        catch (error) {
            console.log(error)
        }
    }

    async function moveOrb(direction) {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;

            const res = await GameInstanceContract.moveOrb(currentCell.row, currentCell.column, direction);

            if (res) {
                const newGrid /* Array<Array<[number, address]>> */ = await GameInstanceContract.getMap();
                setGrid(newGrid);

                const gameStage /* number */ = await GameInstanceContract.getGameStage(); //getGameStage
                setGameStage(gameStage);
            }

        } catch (error) {
            console.log(error);
        }
    }

    async function attackOrb() {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;

            const callData = await attackOrbCallData(energy, salt);
            if (callData) {
                console.log(callData.Input);
                console.log(JSON.stringify(callData.Input));
                const response = await GameInstanceContract.attackOrb(contractAddress.attackVerifierContract, callData.a, callData.b, callData.c, callData.Input);
                console.log(response);
            }

        } catch (error) {
            console.log(error);
        }
    }

    async function defendOrb() {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;

            const attackEnergy = await GameInstanceContract.getEnergyMemory();

            const callData = await defendOrbCallData(attackEnergy, energy, salt);
            if (callData) {
                const response = await GameInstanceContract.defendOrb(contractAddress.defendVerifierContract, callData.a, callData.b, callData.c, callData.Input);
                console.log(response);
                const newEnergy = energy - attackEnergy;
                if (newEnergy < 0) {
                    newEnergy = 0;
                }
                setEnergy(newEnergy);
                console.log(energy);
            }

        } catch (error) {
            console.log(error);
        }
    }

    async function resaltOrb() {
        try {
            if (
                !playerAddress ||
                activeChain.id.toString() !== networks.selectedChain
            ) return;

            const attackerEnergyLeft = await GameInstanceContract.getEnergyMemory();
            console.log(attackerEnergyLeft);
            const callData = await attackerEResaltCallData(attackerEnergyLeft, salt);
            if (callData) {
                console.log(JSON.stringify(callData.Input));
                const response = await GameInstanceContract.setOutcome(contractAddress.outcomeVerifierContract, callData.a, callData.b, callData.c, callData.Input);
                console.log(response);
                setEnergy(attackerEnergyLeft);
            }

        } catch (error) {
            console.log(error);
        }
    }

    /* rendering */
    return (
        <div>
            <button onClick={() => setPlayer2()} className="button bg-cyan-900 color-white px-4 py-3 rounded-md m-1">Join as player2</button>
            <div>
                {grid.map((row, i) => {
                    return (
                        <div key={i} className="grid grid-cols-10" style={{ width: 400 }}>
                            {row.map(([fieldType, fieldOwner], j) => {

                                function getBorderColor() {
                                    if (currentCell.row === i && currentCell.column === j) return "blue";
                                    return undefined;
                                }

                                function getBackground() {
                                    if (fieldOwner === playerAddress) return "green";
                                    if (fieldOwner !== "0x0000000000000000000000000000000000000000") return "red";
                                    if (fieldType === 3) return "gray";
                                    if (fieldType === 1) return "CornflowerBlue";
                                    return undefined;
                                }

                                return (
                                    <div key={`[${i}][${j}]`} onClick={() => setCurrentCell({ column: j, row: i })} className="border-2 h-4" style={{
                                        height: 40, width: 40,
                                        borderColor: getBorderColor(),
                                        background: getBackground()
                                    }}>
                                        {fieldType}
                                    </div>
                                )
                            })}
                        </div>
                    )
                })}
            </div>

            <div>
                <input className="bg-stone-800 text-teal-300 w-15 py-2 rounded-md" type="number" placeholder="energy" onChange={(e) => setEnergy(Number(e.target.value))} />
                <button onClick={handleSpawn} className="button bg-green-600 color-white px-2 py-2 rounded-md m-1">Spawn orb</button>
            </div>
            <div className="grid grid-cols-3" style={{ width: 400 }}>
                <div />
                <button onClick={() => moveOrb(0)} className="button bg-blue-500 color-white px-4 py-3 rounded-md m-1">⬆️</button>
                <div />

                <button onClick={() => moveOrb(3)} className="button bg-blue-500 color-white px-4 py-3 rounded-md m-1">⬅️</button>
                <div />
                <button onClick={() => moveOrb(1)} className="button bg-blue-500 color-white px-4 py-3 rounded-md m-1">➡️</button>

                <div />
                <button onClick={() => moveOrb(2)} className="button bg-blue-500 color-white px-4 py-3 rounded-md m-1">⬇️</button>
                <div />
            </div>
            <div>
                <button onClick={() => attackOrb()} className="button bg-red-500 color-white px-4 py-3 rounded-md m-1">attack</button>
                <button onClick={() => defendOrb()} className="button bg-red-500 color-white px-4 py-3 rounded-md m-1">defend</button>
                <button onClick={() => resaltOrb()} className="button bg-red-500 color-white px-4 py-3 rounded-md m-1">endAttack</button>
            </div>

            <div className="flex bg-slate-600 justify-center">Stage: {STAGES[gameStage]}</div>
            <h1>Game instance: {gameInstanceAddress}</h1>
            <div>Orb energy: {energy}</div>
            <>Selected: (column: {currentCell.column} row: {currentCell.row})</>
        </div>
    )
}



