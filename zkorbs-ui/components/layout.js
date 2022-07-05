import Header from "./header";
import Footer from "./footer";
import Head from "next/head";
import Script from "next/script";
import { WagmiConfig, createClient } from "wagmi";
import { providers } from "ethers";

import networks from "../utils/networks.json";

// Provider that will be used when no wallet is connected (aka no signer)
const provider = providers.getDefaultProvider(
  networks[networks.selectedChain].rpcUrls[0]
);

const client = createClient({
  autoConnect: true,
  provider,
});

export default function Layout({ children }) {
  return (
    <>
      <WagmiConfig client={client}>
        <div className="flex flex-col min-h-screen px-2 bg-slate-900 text-slate-300">
          <Header />
          <main className="mb-auto">{children}</main>
          <Footer />
        </div>
      </WagmiConfig>
    </>
  );
}