// StakeForm.tsx
import React, { useState } from 'react';
import { useMentoStaker } from '@/utils/useMentoStaker'; // Ensure the path is correct

export const StakeForm = ({ userAddress }: { userAddress: string }) => {
  const [amount, setAmount] = useState('');
  const { stake, withdraw, addRewards } = useMentoStaker(); // Using the custom hook

  const handleStake = async () => {
    if (!amount) {
      alert('Please enter an amount to stake.');
      return;
    }
    try {
      await stake(amount);
      alert('Stake successful');
    } catch (error) {
      alert('Stake failed: ' + (error as Error).message);
    }
  };

  const handleWithdraw = async () => {
    try {
      await withdraw();
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
      await addRewards(amount);
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
        placeholder="Amount to stake or reward"
      />
      <button onClick={handleStake}>Stake</button>
      <button onClick={handleWithdraw}>Withdraw</button>
      <button onClick={handleAddRewards}>Add Rewards</button>
    </div>
  );
};
