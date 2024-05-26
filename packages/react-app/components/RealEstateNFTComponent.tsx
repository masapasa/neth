import { useState } from "react";
import { ethers } from "ethers";

require('../../hardhat/artifacts/contracts/MentoStaker.sol/MentoStaker.json').abi;
const CONTRACT_ADDRESS = '0x601e3F1DD9b528e08e63d91aa4C1D79B900fD56C';

const RealEstateNFTComponent = () => {
  const [walletAddress, setWalletAddress] = useState("");
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [tokenPriceDetails, setTokenPriceDetails] = useState(null);
  const [tokenId, setTokenId] = useState("");
  const connectWallet = async () => {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      setWalletAddress(await signer.getAddress());
      setContract(new ethers.Contract(CONTRACT_ADDRESS, ABI, signer));
    } else {
      alert("Install MetaMask to interact with this application.");
    }
  };
  const fetchTokenPriceDetails = async () => {
    if (contract && tokenId) {
      const priceDetails = await contract.getPriceDetails(tokenId);
      setTokenPriceDetails(priceDetails);
    }
  };
  const issueNFT = async (to: string) => {
    if (contract) {
      await contract.issue(to, your_subscription_id, gas_limit, don_id);
    }
  };
  const crossChainTransfer = async (from: string, to: string, id: number, chainSelector: number, payFeesIn: string) => {
    if (contract) {
      const tx = await contract.crossChainTransferFrom(from, to, id, chainSelector, payFeesIn);
      await tx.wait();
      alert("Transfer Complete");
    }
  };
  return (
    <div>
      <h1>Real Estate NFT Interaction</h1>
      {!walletAddress ? (
        <button onClick={connectWallet}>Connect Wallet</button>
      ) : (
        <div>
          <p>Wallet Address: {walletAddress}</p>
          <div>
            <h2>Fetch Token Price Details</h2>
            <input
              type="text"
              value={tokenId}
              onChange={(e) => setTokenId(e.target.value)}
              placeholder="Token ID"
            />
            <button onClick={fetchTokenPriceDetails}>Fetch Details</button>
            {tokenPriceDetails && (
              <div>
                <p>List Price: {tokenPriceDetails.listPrice}</p>
                <p>Original List Price: {tokenPriceDetails.originalListPrice}</p>
                <p>Tax Assessed Value: {tokenPriceDetails.taxAssessedValue}</p>
              </div>
            )}
          </div>
          <div>
            <h2>Issue NFT</h2>
            <input type="text" placeholder="Recipient Address" id="recipient" />
            <button onClick={() => issueNFT((document.getElementById("recipient") as HTMLInputElement).value)}>
              Issue NFT
            </button>
          </div>
          <div>
            <h2>Cross Chain Transfer</h2>
            <input type="text" placeholder="From Address" id="from" />
            <input type="text" placeholder="To Address" id="to" />
            <input type="number" placeholder="Token ID" id="transferTokenId" />
            <input type="number" placeholder="Destination Chain Selector" id="chainSelector" />
            <select id="payFeesIn">
              <option value="0">Native</option>
              <option value="1">LINK</option>
            </select>
            <button onClick={() => crossChainTransfer(
              (document.getElementById("from") as HTMLInputElement).value,
              (document.getElementById("to") as HTMLInputElement).value,
              parseInt((document.getElementById("transferTokenId") as HTMLInputElement).value, 10),
              parseInt((document.getElementById("chainSelector") as HTMLInputElement).value, 10),
              (document.getElementById("payFeesIn") as HTMLSelectElement).value
            )}>
              Transfer Cross Chain
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
export default RealEstateNFTComponent;