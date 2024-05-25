// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "./MentoStaker.sol";
import "./mocks/MockERC20.sol";

contract MentoStakerTest is Test {
    MentoStaker public mentoStaker;
    MockERC20 public cEURToken;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this); // Test contract is the owner
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy Mock cEUR Token
        cEURToken = new MockERC20("Mock cEUR", "cEUR", 18);

        // Deploy MentoStaker contract
        mentoStaker = new MentoStaker(address(cEURToken));

        // Mint cEUR tokens for testing
        cEURToken.mint(user1, 1e18); // 1 cEUR
        cEURToken.mint(user2, 2e18); // 2 cEUR

        // Approve MentoStaker contract to spend users' cEUR
        vm.startPrank(user1);
        cEURToken.approve(address(mentoStaker), 1e18);
        vm.stopPrank();

        vm.startPrank(user2);
        cEURToken.approve(address(mentoStaker), 2e18);
        vm.stopPrank();
    }

    function testStake() public {
        // User1 stakes 1 cEUR
        vm.startPrank(user1);
        mentoStaker.stake(1e18);
        vm.stopPrank();

        assertEq(mentoStaker.totalStaked(), 1e18, "Total staked should be 1 cEUR");
        assertEq(mentoStaker.stakes(user1).amount, 1e18, "User1's staked amount should be 1 cEUR");
    }

    function testAddRewards() public {
        // Owner adds 0.5 cEUR as rewards
        cEURToken.mint(address(this), 5e17); // 0.5 cEUR
        cEURToken.approve(address(mentoStaker), 5e17);
        mentoStaker.addRewards(5e17);

        assertEq(mentoStaker.totalRewards(), 5e17, "Total rewards should be 0.5 cEUR");
    }

    function testWithdraw() public {
        // Setup: User1 stakes 1 cEUR
        vm.startPrank(user1);
        mentoStaker.stake(1e18);
        vm.stopPrank();

        // Owner adds 0.5 cEUR as rewards
        cEURToken.mint(address(this), 5e17); // 0.5 cEUR
        cEURToken.approve(address(mentoStaker), 5e17);
        mentoStaker.addRewards(5e17);

        // User1 withdraws stake + rewards
        uint256 user1BalanceBefore = cEURToken.balanceOf(user1);
        vm.startPrank(user1);
        mentoStaker.withdraw();
        vm.stopPrank();
        uint256 user1BalanceAfter = cEURToken.balanceOf(user1);

        // Assuming rewards are distributed equally and only user1 staked, they should receive all rewards
        assertEq(user1BalanceAfter - user1BalanceBefore, 15e17, "User1 should withdraw 1.5 cEUR (stake + rewards)");
    }
}
