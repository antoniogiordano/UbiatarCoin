pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./Owned.sol";

contract UAC {
    function transfer(address _to, uint256 _value) public returns(bool);
}

contract FoundersVesting is Owned
{
    using SafeMath for uint;

    bool public icoFinished = false;

    address public icoContractAddress = 0x0;

    address public uacTokenAddress = 0x0;

    address public foundersTokenHolder = 0x0;

    uint public amountToSend = 0;

    uint public lastWithdrawTime;

    UAC public uacToken;

    uint public currentBalance = 12000000 * 1 ether;

    uint public balanceFraction;

    function FoundersVesting(address _uacTokenAddress)
    {
        require(_uacTokenAddress != 0x0);

        uacToken = UAC(_uacTokenAddress);
        uacTokenAddress = _uacTokenAddress;
        balanceFraction = ((currentBalance.mul(1 ether)).div(360 days)).div(1 ether);
    }

    modifier byIcoContract()
    {
        require(msg.sender == icoContractAddress);
        _;
    }

    modifier onlyIcoFinished()
    {
        require(icoFinished == true);
        _;
    }

    function icoFinished()
    byIcoContract
    {
        lastWithdrawTime.add(360 days);
        icoFinished = true;
    }

    function setIcoContractAddress(address _icoContractAddress)
    public
    onlyOwner
    {
        icoContractAddress = _icoContractAddress;
    }

    function setUacTokenAddress(address _uacTokenAddress)
    onlyOwner
    {
        uacTokenAddress = _uacTokenAddress;
        uacToken = UAC(_uacTokenAddress);
    }

    function setFoundersTokenHolder(address _foundersTokenHolder)
    public
    onlyOwner
    {
        foundersTokenHolder = _foundersTokenHolder;
    }

    function withdrawTokens()
    public
    onlyOwner
    onlyIcoFinished
    {
        amountToSend = 0;
        uint daysPassed = (uint(now).sub(lastWithdrawTime)).div(1 days);
        amountToSend = balanceFraction.mul(daysPassed);
        lastWithdrawTime = uint(now);

        require(amountToSend != 0);

        if (currentBalance < amountToSend) {
            amountToSend = currentBalance;
        }

        currentBalance = currentBalance.sub(amountToSend);

        uacToken.transfer(foundersTokenHolder, amountToSend);

        amountToSend = 0;
    }

    // Do not allow to send money directly to this contract
    function() payable {
        revert();
    }
}
