import { exportCallDataGroth16 } from "../snarkjsZkproof";

export async function initCallData(energy, salt) {
    const input = {
        energy: energy,
        salt: salt,
    };
    let dataResult;
    try {
        dataResult = await exportCallDataGroth16(
            input,
            "/zkproof/Init.wasm",
            "/zkproof/Init_final.zkey"
        );
    } catch (error) {
        console.log(error);
        window.alert("Wrong input (must be between 1-100)");
    }
    return dataResult;
}

export async function defendOrbCallData(attackEnergy, defendEnergy, salt) {
    const input = {
        attackEnergy: attackEnergy,
        defendEnergy: defendEnergy,
        salt: salt,
    };
    let dataResult;
    try {
        dataResult = await exportCallDataGroth16(
            input,
            "/zkproof/DefendOrb.wasm",
            "/zkproof/DefendOrb_final.zkey"
        );
    } catch (error) {
        console.log(error);
        window.alert("Something went wrong with defence");
    }
    return dataResult;
}

export async function attackOrbCallData(attackEnergy, salt) {
    const input = {
        attackEnergy: attackEnergy,
        salt: salt,
    };
    let dataResult;
    try {
        dataResult = await exportCallDataGroth16(
            input,
            "/zkproof/AttackOrb.wasm",
            "/zkproof/AttackOrb_final.zkey"
        );
    } catch (error) {
        console.log(error);
        window.alert("Something went wrong with attack");
    }
    return dataResult;
}

export async function attackerEResaltCallData(attackerEnergyLeft, salt) {
    const input = {
        attackerEnergyLeft: attackerEnergyLeft,
        salt: salt,
    };
    let dataResult;
    try {
        dataResult = await exportCallDataGroth16(
            input,
            "/zkproof/AttackerEResalt.wasm",
            "/zkproof/AttackerEResalt_final.zkey"
        );
    } catch (error) {
        console.log(error);
        window.alert("Something went wrong with fight outcome");
    }
    return dataResult;
}