import Head from "next/head";
import { useRouter } from "next/router";
import GameFactoryAbi from "../utils/abiFiles/GameFactory.json";
import contractAddress from "../utils/contractaddress.json";
import networks from "../utils/networks.json";
import {
  useAccount,
  useNetwork,
  useSigner,
  useProvider,
  useContract,
  useWaitForTransaction
} from 'wagmi';

import { useState, useEffect } from "react";

function Home() {
  /* next hooks */
  const router = useRouter();

  /* wagmi hooks */
  const { activeChain } = useNetwork();
  const { data: dataAccount } = useAccount();
  const { data: signer } = useSigner();
  const provider = useProvider();

  const GameFactoryContract = useContract({
    addressOrName: contractAddress.gameFactoryContract,
    contractInterface: GameFactoryAbi.abi,
    signerOrProvider: signer || provider,
  });

  const [activeGameInstances, setActiveGameInstances] = useState([]);

  useEffect(() => {
    /* view function gets viewed when page starts rendering */
    async function fetchActiveInstances() {
      const activeGameInstances /* Array<string> */ = await GameFactoryContract.getActive();
      setActiveGameInstances(activeGameInstances)
    };
    fetchActiveInstances();
  }, [])

  // dataAccount.address
  const [playerAddress, setPlayerAddress] = useState();
  useEffect(() => {
    if (dataAccount) {
      setPlayerAddress(dataAccount.address);
    }
  }, [dataAccount]);

  async function handleCreate(e) {
    e.preventDefault();

    try {
      if (
        !playerAddress ||
        activeChain.id.toString() !== networks.selectedChain
      ) return;

      const res = await GameFactoryContract.createGameInstance(playerAddress);

      // if (res) {
      //   const newActive = await GameFactoryContract.getActive();

      //   const lastCreatedInstance = newActive[newActive.length - 1];
      //   router.push(`/gridboard?gameInstanceAddress=${lastCreatedInstance}`);
      // }

    } catch (error) {
      console.log(error);
    }
  }

  return /* rendering */ (
    <div>
      <h1>Game Instances List</h1>

      <button onClick={handleCreate} className="button bg-blue-500 color-white px-4 py-3 rounded-md">Create</button>

      <div className="grid border">
        {activeGameInstances.map(address => {
          return (
            <button key={address} onClick={() => router.push(`/gridboard?gameInstanceAddress=${address}`)}>
              {address /* renders as text */}
            </button>
          )
        })}
      </div>
    </div>
  )
}

export default Home

