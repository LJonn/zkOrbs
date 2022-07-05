const hre = require("hardhat");

async function main() {

    //Deploying Contracts
    const Factory = await hre.ethers.getContractFactory("GameFactory");
    const factory = await Factory.deploy();
    await factory.deployed();
    console.log("GameFactory deployed to:", factory.address);

    const FactoryInit = await hre.ethers.getContractFactory("InitVerifier");
    const factoryInit = await FactoryInit.deploy();
    await factoryInit.deployed();
    console.log("InitVerifier deployed to:", factoryInit.address);

    const FactoryAttack = await hre.ethers.getContractFactory("AttackOrbVerifier");
    const factoryAttack = await FactoryAttack.deploy();
    await factoryAttack.deployed();
    console.log("AttackOrbVerifier deployed to:", factoryAttack.address);

    const FactoryDefend = await hre.ethers.getContractFactory("DefendOrbVerifier");
    const factoryDefend = await FactoryDefend.deploy();
    await factoryDefend.deployed();
    console.log("DefendOrbVerifier deployed to:", factoryDefend.address);

    const FactoryOutcome = await hre.ethers.getContractFactory("AttackerEResaltVerifier");
    const factoryOutcome = await FactoryOutcome.deploy();
    await factoryOutcome.deployed();
    console.log("AttackerEResaltVerifier deployed to:", factoryOutcome.address);

    // //Calling contract functions
    // const firstInstance = await factory.createGameInstance(
    //     "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" //HH Account#0
    // );


    // const secondInstance = await factory.createGameInstance(
    //     "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" //HH Account#1
    // );
    // const instanceAddresses = await factory.getActive();
    // console.log("instance1 deployed to:", instanceAddresses[0]);
    // console.log("instance2 deployed to:", instanceAddresses[1]);
    //     "secondInstance",
    //     "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    //     hre.ethers.constants.AddressZero, //send address(0) for others to join
    //     [[1,0,0,0,0,0,0,0,0,0],
    //     [0,0,0,2,2,0,0,0,0,0],
    //     [0,0,0,0,0,0,0,0,0,0],
    //     [1,1,1,0,0,0,1,1,1,1],
    //     [1,0,0,0,0,0,1,0,0,3],
    //     [3,0,0,1,0,0,0,0,0,1],
    //     [1,1,1,1,0,0,0,1,1,1],
    //     [0,0,0,0,0,0,0,0,0,0],
    //     [0,0,0,0,0,0,0,0,0,0],
    //     [0,0,0,0,0,0,0,0,0,1]]
    //     );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });