import { useEffect, useState } from "react";
import { useAccount } from "wagmi";
import dynamic from "next/dynamic";
import { StakeForm } from "@/components/StakeForm";
const RealEstateNFTComponent = dynamic(() => import("../components/RealEstateNFTComponent"), { ssr: false });
const HomePage = () => {
  return (
    <div>
      <h1>Welcome to Real Estate NFT Platform</h1>
      <RealEstateNFTComponent />
    </div>
    <div>
      <h1>Stake Form</h1>
      <StakeForm />
    </div>
  );
};
export default HomePage;