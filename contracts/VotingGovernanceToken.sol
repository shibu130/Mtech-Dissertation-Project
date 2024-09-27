// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract VotingGovernanceToken is ERC20{

    // initially 
      address  immutable public owner;
      uint256 public batchAmount;
      address public treasuryAddress;

    constructor(uint256 amount, address treasury) ERC20("Voting Governance Token","VOGT"){

        // mint a big amount to the treasury token
        // 
       // _mint(msg.sender, initialSupply);
       owner = msg.sender;
       batchAmount = amount;
       treasuryAddress = treasury;
       // 7 lakh tokens to the owner
       // we will transfer tokens to the treasury later
       _mint(treasuryAddress, batchAmount * (10 ** 18));
      
    }

    function mintTokenToTreasury() external {

         _mint(treasuryAddress, batchAmount * (10 ** 18));
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"only owner can do this operation");
        _;
    }

    function _specialApprove(address _owner, address spender, uint256 value, bool) external     {

        super._approve(_owner,  spender,  value, true);
    }
}