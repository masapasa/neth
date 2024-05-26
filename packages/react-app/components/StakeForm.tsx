// StakeForm.tsx
import React, { useState } from 'react';
import { addRewards, stake, withdraw } from '@/utils/interact';
import { useAccount } from "wagmi";

export const StakeForm = ({ userAddress }: { userAddress: string }) => {
  const [amount, setAmount] = useState('');
  const { connect } = useAccount();

  const handleConnect = async () => {
    try {
      await connect();
    } catch (error) {
      alert('Connection failed: ' + (error as Error).message);
    }
  };

  const handleStake = async () => {
    if (!amount) {
      alert('Please enter an amount to stake.');
      return;
    }
    try {
      await stake(amount, userAddress);
      alert('Stake successful');
    } catch (error) {
      alert('Stake failed: ' + (error as Error).message);
    }
  };

  const handleWithdraw = async () => {
    try {
      await withdraw(userAddress);
      alert('Withdraw successful');
    } catch (error) {
      alert('Withdraw failed: ' + (error as Error).message);
    }
  };

  const handleAddRewards = async () => {
    if (!amount) {
      alert('Please enter an amount to add as rewards.');
      return;
    }
    try {
      await addRewards(amount, userAddress);
      alert('Rewards added successfully');
    } catch (error) {
      alert('Failed to add rewards: ' + (error as Error).message);
    }
  };

  return (
    <div>
      <input
        type="text"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="Amount to stake"
      />
      <button onClick={handleStake}>Stake</button>
      <button onClick={handleWithdraw}>Withdraw</button>
      <button onClick={handleAddRewards}>Add Rewards</button>
    </div>
  );
};
