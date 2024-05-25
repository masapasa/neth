// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MentoStaker {
	error NotOwner();
	error AmountShouldBeMoreThanZero();
	error NoBalanceToWithdraw();
	error WithdrawFailed();
	error NotEnoughRewards();

	struct Stake {
		uint256 amount;
		uint256 rewardDebt;
	}

	address public owner;
    IERC20 public cEURToken;
	uint256 public totalStaked;
	uint256 public totalRewards;
	uint256 public accRewardPerShare;
	mapping(address => Stake) public stakes;

	event StakeMade(address indexed user, uint256 amount);
	event Withdrawn(
		address indexed user,
		uint256 stakeAmount,
		uint256 rewardAmount
	);
	event RewardAdded(uint256 rewardAmount);

	modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
		_;
	}

    constructor(address _cEURTokenAddress) {
		owner = msg.sender;
        cEURToken = IERC20(_cEURTokenAddress);
	}
	function updateAccRewardPerShare() internal {
		if (totalStaked > 0) {
			accRewardPerShare += (totalRewards * 1e12) / totalStaked;
		}
	}

    function stake(uint256 _amount) public {
		console.log("Staking amount:", _amount); // Debugging line
        require(_amount > 0, "AmountShouldBeMoreThanZero");
        require(cEURToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

		updateAccRewardPerShare();

		Stake storage userStake = stakes[msg.sender];
		if (userStake.amount > 0) {
            uint256 pendingReward = (userStake.amount * accRewardPerShare / 1e12) - userStake.rewardDebt;
            if (pendingReward > 0) {
                cEURToken.transfer(msg.sender, pendingReward);
			totalRewards -= pendingReward;
            }
		}

        userStake.amount += _amount;
        totalStaked += _amount;
        userStake.rewardDebt = userStake.amount * accRewardPerShare / 1e12;

        emit StakeMade(msg.sender, _amount);
	}

    function addRewards(uint256 _rewardAmount) public onlyOwner {
        require(cEURToken.transferFrom(msg.sender, address(this), _rewardAmount), "Transfer failed");
        totalRewards += _rewardAmount;
		updateAccRewardPerShare();
        emit RewardAdded(_rewardAmount);
	}

	function withdraw() public {
    Stake storage userStake = stakes[msg.sender];
    require(userStake.amount > 0, "NoBalanceToWithdraw");

    updateAccRewardPerShare();
    uint256 pendingReward = (userStake.amount * accRewardPerShare / 1e12) - userStake.rewardDebt;
    uint256 totalWithdraw = userStake.amount + pendingReward;

    // Check cEURToken balance instead of contract's ETH balance
    require(cEURToken.balanceOf(address(this)) >= totalWithdraw, "NotEnoughRewards");

    userStake.amount = 0;
    userStake.rewardDebt = 0;
    totalStaked -= userStake.amount;

    require(cEURToken.transfer(msg.sender, totalWithdraw), "WithdrawFailed");

    emit Withdrawn(msg.sender, userStake.amount, pendingReward);
}

	function ownerWithdraw() external onlyOwner {
		(bool success, ) = owner.call{ value: address(this).balance }("");
		require(success, "WithdrawFailed");
	}
}