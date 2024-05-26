import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

const MentoStakerABI = require('../../hardhat/artifacts/contracts/MentoStaker.sol/MentoStaker.json').abi;
const contractAddress = '0x601e3F1DD9b528e08e63d91aa4C1D79B900fD56C'; // Replace with your contract's address

export const useMentoStaker = () => {
  const [contract, setContract] = useState(null);

  useEffect(() => {
    if (typeof window.ethereum !== 'undefined') {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const mentoStakerContract = new ethers.Contract(contractAddress, MentoStakerABI, signer);
      setContract(mentoStakerContract);
    }
  }, []);

  const readContract = async () => {
    if (!contract) return;
    const totalStaked = await contract.totalStaked();
    const totalRewards = await contract.totalRewards();
    return { totalStaked: ethers.utils.formatEther(totalStaked), totalRewards: ethers.utils.formatEther(totalRewards) };
  };

  const stake = async (amount) => {
    if (!contract) return;
    const tx = await contract.stake(ethers.utils.parseEther(amount.toString()));
    await tx.wait();
  };

  const withdraw = async () => {
    if (!contract) return;
    const tx = await contract.withdraw();
    await tx.wait();
  };

  const addRewards = async (amount) => {
    if (!contract) return;
    const tx = await contract.addRewards(ethers.utils.parseEther(amount.toString()));
    await tx.wait();
  };

  return { stake, withdraw, addRewards, readContract };
};