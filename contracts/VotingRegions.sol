// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface  IAccessControl{
    function getRoleOfAddress(address addressOfUser, bytes32 role) external  view returns (bool);
}



contract VotingRegions{

    string[]  public  votingRegions;
    address public  owner;
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant USER = keccak256("USER");
    bytes32 public constant CANDIDATE = keccak256("CANDIDATE");
    bytes32 public constant DEPLOYER = keccak256("DEPLOYER");

    address public contractAddress;


     constructor(string[] memory regions, address accessControlAddress){

        owner = msg.sender;
        // get regions from contructor rather than hardcoding stuff
        votingRegions = regions;

        contractAddress = accessControlAddress;

    }

    function getRegions() public view returns (string[] memory){

        return votingRegions;
        
    }
 
    function addRegions(string memory region)  external {
        // ivoke the call to access permission

         bool a = IAccessControl(contractAddress).getRoleOfAddress(msg.sender,ADMIN);
        require(a, "only the admins can add regions");

        for(uint256 i=0 ; i<votingRegions.length; i++){

            
            if( keccak256(bytes(votingRegions[i])) == keccak256(bytes(region))){

                require(false,"the region is a duplicate");
            }

        }
        

        votingRegions.push(region);
    }

    modifier onlyOwner(){

        require(msg.sender == owner,"u can do this operation");
        _;
    }
    
}