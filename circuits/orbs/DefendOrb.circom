pragma circom 2.0.3;

include "circomlib/poseidon.circom";
include "circomlib/comparators.circom";

template DefendOrb () {
    
    signal input attackEnergy;
    signal input defendEnergy;
    signal input salt;

    signal output attackerEnergyLeft;
    signal output defendHashCheck;

    signal isGreater;
    
    component poseidon = Poseidon(2);
    poseidon.inputs[0] <== defendEnergy;
    poseidon.inputs[1] <== salt;
    defendHashCheck <== poseidon.out;

    component greaterThan = GreaterThan(4);
    greaterThan.in[0] <== defendEnergy;
    greaterThan.in[1] <== attackEnergy;
    isGreater <== greaterThan.out;
    attackerEnergyLeft <== attackEnergy-defendEnergy+2*isGreater*(defendEnergy-attackEnergy);

}

component main { public [ attackEnergy ] } = DefendOrb();