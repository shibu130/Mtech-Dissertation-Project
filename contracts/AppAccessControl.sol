// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/AccessControl.sol";
pragma solidity ^0.8.17;
contract AppAccessControl is AccessControl{

// Errors

error UserExists(address UserAddress);


// define the user roles mainly admin and 
bytes32 public constant ADMIN = keccak256("ADMIN");
bytes32 public constant USER = keccak256("USER");
bytes32 public constant CANDIDATE = keccak256("CANDIDATE");
bytes32 public constant DEPLOYER = keccak256("DEPLOYER");
// in this scenario the candidate cant vote for himself


mapping(address=>UserType) public UserMapping;
address[] public User;
mapping(address=>CandidateType) public CandidateMapping;
address[] public Candidate;
mapping(address => AdminUserType ) public AdminUserMapping;
address[] public Admin;






struct UserType{
    string Name;
    address UserAddress;
    string Region;
    uint256 VotingPower;
}


struct VotingDetails{
    uint256 ProposalId;
    uint256 ProposalOption;
}



struct AdminUserType{
    uint256 VotingPower;
}


// can have nft like a trophy showcase winner
struct CandidateType{
    string Name;
    address CandidateAddress;
    string Region;

}

// we take a set of guys make them the admin , users and candidates need to be created and added through the proposal
    constructor( address[] memory addressList)
    {
        // if we want to send the governance tokens  to the admin roles
        // we need to make sure the erc20 tokens is minted before hand
        //  and then mint the token to treasury
        _grantRole(DEPLOYER, msg.sender);

        for(uint256 i=0; i<addressList.length; i++){
            _grantRole(ADMIN, addressList[i]);
            AdminUserMapping[addressList[i]].VotingPower = 0;
            Admin.push(addressList[i]);
        }

        // governance token can be sent 
    }

 
    function getRoleOfAddress(address addressOfUser, bytes32 role) public view returns (bool){
            return hasRole(role, addressOfUser);
    }




    // instead of doing something like selecting stuff from ui the users of the users can just  request to be part of the application

    function requestToBeAddedAsUser(address addressOfUser, string memory _name, string memory _region   )  external {


        // make sure the guy doesnt have an existing role , else revert


        if(!hasRole(ADMIN, addressOfUser) &&  !hasRole(USER, addressOfUser) && !hasRole(CANDIDATE, addressOfUser) && !hasRole(CANDIDATE, addressOfUser)){

            // add guy as user
              _grantRole(USER, addressOfUser);

            // update the mappings
            UserMapping[addressOfUser].UserAddress = addressOfUser;
            UserMapping[addressOfUser].Name = _name;
            UserMapping[addressOfUser].Region = _region;
            // once they delegate to the election contract the voting power increases
            // undelegating decreases voting power
            UserMapping[addressOfUser].VotingPower = 0;
            // need this
            // the language doesnt have a way to retrieve keys of mapping unless u loop
            // which is painful casuing a complexity of O(n)
            User.push(addressOfUser);
        }
        else{
            // prevent a duplicate registration 
            // already existing users cannot be assigned a role again just to be safe and prevent
            // duplicate voting
            // throw error for ui purpose
            // revert UserExists({
            //     UserAddress: addressOfUser
            // });
        }
    }



    // grant access to users , happens after the proposal though
    // function addUsersToApp(address initiator, UserType[] memory userAddresses) external {

    //     // check if the intiator is admin which has to as the proposals become success or fail
    //     // the person who will be executing will be the admins only 
    //     // prevent someone 
    //     require(hasRole(ADMIN, initiator), "only admins can do this process");

    //     for(uint256 i; i<userAddresses.length; i++){
    //         _grantRole(USER, userAddresses[i].UserAddress);
    //         // update the mappings
    //         UserMapping[userAddresses[i].UserAddress].UserAddress = userAddresses[i].UserAddress;
    //         UserMapping[userAddresses[i].UserAddress].Name = userAddresses[i].Name;
    //         UserMapping[userAddresses[i].UserAddress].Region = userAddresses[i].Region;
    //         // once they delegate to the election contract the voting power increases
    //         // undelegating decreases voting power
    //         UserMapping[userAddresses[i].UserAddress].VotingPower = 0;
    //         // need this
    //         // the language doesnt have a way to retrieve keys of mapping unless u loop
    //         // which is painful
    //         User.push(userAddresses[i].UserAddress);
    //         // mint token
    //     }
    // }

    
    // // grant access to users , happens after the proposal though
    // function addCandidateToApp(address initiator, CandidateType[] memory userAddresses) external {
    //     // check if the intiator is admin which has to as the proposals become success or fail
    //     // the person who will be executing will be the admins only 
    //     // prevent someone 
    //     require(hasRole(ADMIN, initiator), "only admins can do this process");

    //     for(uint256 i; i<userAddresses.length; i++){
    //         //  string Name;
    //         // address CandidateAddress;
    //         // string Region;
    //         _grantRole(CANDIDATE, userAddresses[i].CandidateAddress);
    //         CandidateMapping[userAddresses[i].CandidateAddress].CandidateAddress = userAddresses[i].CandidateAddress;
    //         CandidateMapping[userAddresses[i].CandidateAddress].Name = userAddresses[i].Name;
    //         CandidateMapping[userAddresses[i].CandidateAddress].Region = userAddresses[i].Region;

    //     }
    // }

    function adminAddress() public view returns (address[] memory admins) {
        return Admin;
    }

    function getAdminDetailsByAddress(address adminAddres) public view returns(AdminUserType memory){
        return AdminUserMapping[adminAddres];
    }


    function userAddress() public view returns (address[] memory users){
        return  User;
    }

    function getUserDetailsByAddress(address  addressOfUser) public view returns(UserType memory){

        return UserMapping[addressOfUser];
    }

    function candidateAddress() public view returns (address[] memory candidate){

        return Candidate;
    }

    function getCandidateDetailsByAddress(address addressOfCandidate) public view returns(CandidateType memory){
        return CandidateMapping[addressOfCandidate];
     }


    function incrementVotingPowerForAdmin(address useradminAddress) public{

        // call this after the token transfer is fully complete

        require(hasRole(ADMIN, useradminAddress), "only admins can do this process");

        AdminUserMapping[useradminAddress].VotingPower = AdminUserMapping[useradminAddress].VotingPower + 1 ;

    }

    
    function decrementVotingPowerForAdmin(address useradminAddress) public{

        // call this after the token transfer is fully complete

        require(hasRole(ADMIN, useradminAddress), "only admins can do this process");

        if(AdminUserMapping[useradminAddress].VotingPower >= 1){
                    AdminUserMapping[useradminAddress].VotingPower = AdminUserMapping[useradminAddress].VotingPower - 1 ;
        }


    }


      function incrementVotingPowerForUser(address useradminAddress) public{

        // call this after the token transfer is fully complete

        require(hasRole(USER, useradminAddress), "only user power can be incremented");

        UserMapping[useradminAddress].VotingPower = UserMapping[useradminAddress].VotingPower + 1 ;

    }

    
    function decrementVotingPowerForUser(address useradminAddress) public{

        // call this after the token transfer is fully complete

        require(hasRole(USER, useradminAddress), "only user power can be incremented");

        if(UserMapping[useradminAddress].VotingPower >= 1){
                    UserMapping[useradminAddress].VotingPower = UserMapping[useradminAddress].VotingPower - 1 ;
        }


    }



}