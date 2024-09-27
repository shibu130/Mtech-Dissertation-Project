// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Treasury{

     address public owner;

     constructor(){
        owner = msg.sender;
     }

    // tranfer eth just in case
    function withdraw(uint amount, address payable destAddr) public   { 
        //require(proposalId != 0, "the proposal id cannot be 0");
        destAddr.transfer(amount);
       
    }
    
    function transferERC20(IERC20 token, address to, uint256 amount) public   {
        uint256 erc20balance = token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is too low");

        // transaction will revert if the erc20 token 
        token.approve(address(this), amount);
        // 2 ways either make sure token is minted abundantly to prevent the above error
        token.transfer(to, amount);
        // we need to pause the election and 
    }  

    



    modifier onlyOwner(){

        require(msg.sender == owner, "only owner can withdraw the funds");
        _;
    }



}