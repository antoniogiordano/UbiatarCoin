pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./StdToken.sol";
import "./Owned.sol";

contract UAC is StdToken, Owned
{

    using SafeMath for uint;
    // Fields:
    string public constant name = "Ubiatar Coin";
    string public constant symbol = "UAC";
    uint public constant decimals = 18;

    address public owner = 0x0;
    address public icoContractAddress = 0x0;
    bool public lockTransfers = false;

    // Update with value of 15 mln + PreSale + founders + bounties
    uint public constant TOTAL_TOKEN_SUPPLY = 35584778551358900100698693;
    // total presale token supply
    uint public constant TOTAL_PRESALE_SUPPLY = 17584778551358900100698693;

    /// Modifiers:
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

    modifier byIcoContract()
    {
        require(msg.sender == icoContractAddress);
        _;
    }

    // Setters/Getters
    function setIcoContractAddress(address _icoContractAddress)
    onlyOwner
    {
        icoContractAddress = _icoContractAddress;
    }

    // Functions:
    function UAC()
    {
        owner = msg.sender;

        assert(TOTAL_TOKEN_SUPPLY == 35584778551358900100698693);
    }

    /// @dev Override
    function transfer(address _to, uint256 _value)
    public
    returns(bool)
    {
        require(!lockTransfers);
        return super.transfer(_to,_value);
    }

    /// @dev Override
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns(bool)
    {
        require(!lockTransfers);
        return super.transferFrom(_from,_to,_value);
    }

    function issueTokens(address _who, uint _tokens)
    byIcoContract
    {
        require((totalSupply + _tokens) <= TOTAL_TOKEN_SUPPLY);

        balances[_who] = balances[_who].add(_tokens);
        totalSupply = totalSupply.add(_tokens);

        Transfer(0x0, _who, _tokens);
    }

    // For refunds only
    function burnTokens(address _who, uint _tokens)
    byIcoContract
    {
        balances[_who] = balances[_who].sub(_tokens);
        totalSupply = totalSupply.sub(_tokens);
    }

    function lockTransfer(bool _lock)
    byIcoContract
    {
        lockTransfers = _lock;
    }

    // Do not allow to send money directly to this contract
    function() {
        revert();
    }
}