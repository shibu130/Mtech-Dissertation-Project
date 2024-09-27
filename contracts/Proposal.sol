// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// nft token
interface IElectionWinner {
   function safeMint(address to, string memory uri) external;  
}


interface  IVotingGovernanceToken {
        function _specialApprove(address _owner, address spender, uint256 value, bool) external;
}

interface  IAccessControl{
   
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

struct CandidateType{
    string Name;
    address CandidateAddress;
    string Region;

}

    function getRoleOfAddress(address addressOfUser, bytes32 role) external  view returns (bool);

    //function addUsersToApp(address initiator, UserType[] memory userAddresses) external;

    //function addCandidateToApp(address initiator, CandidateType[] memory userAddresses) external;

    function adminAddress() external  view returns (address[] memory admins);

    function getAdminDetailsByAddress(address adminAddres) external  view returns(AdminUserType memory);

    function userAddress() external  view returns (address[] memory users);

    function getUserDetailsByAddress(address  addressOfUser) external  view returns(UserType memory);

    function candidateAddress() external  view returns (address[] memory candidate);
    
    function getCandidateDetailsByAddress(address addressOfCandidate) external  view returns(CandidateType memory);

    function incrementVotingPowerForAdmin(address useradminAddress) external;

    function decrementVotingPowerForAdmin(address useradminAddress) external ;

    function requestToBeAddedAsUser(address addressOfUser, string memory _name, string memory _region   )  external;

    function incrementVotingPowerForUser(address useradminAddress) external;

    function decrementVotingPowerForUser(address useradminAddress) external;
}

interface ITreasury {
        function transferERC20(IERC20 token, address to, uint256 amount) external;
}

contract Proposals{

    error AlreadyVotedForProposal(address UserAddress);

    address public immutable  owner;
    bytes32 public immutable  ADMIN = keccak256("ADMIN");
    bytes32 public immutable USER = keccak256("USER");
    bytes32 public immutable CANDIDATE = keccak256("CANDIDATE");
    bytes32 public immutable DEPLOYER = keccak256("DEPLOYER");
    address public immutable accessControlContractAddress;
    address public immutable treasuryAddress;
    address public immutable ielectionwinnerAddress;

    IERC20 public immutable token;

    address public immutable tokenAddress;

    uint256 public UniquePrposalId;

    uint256 public UniqueElectionId;

    struct maxVotesInAnElection{

        address candidateAddress;
        uint256 votes;
        bool tied;

    }

    mapping(uint256=> maxVotesInAnElection) electionMaxVote;


    struct ElectionDetails{

        uint256 Id;
        address Winner;
        uint256 WinnerVote;
        uint256 StartDate;
        uint256 EndDate;
        string Region;
        string Status;
    
    }

    struct ElectionVotingHistory{
        address choice;
        bool voted;
    }

    struct candidateVoteCount{
        uint256 count;
    }

    ElectionDetails[] public electionList; 
    
    mapping(uint256 => mapping (address => ElectionVotingHistory)) public ElectionHistory;

    mapping(uint256 => mapping(address => candidateVoteCount)) public candidateVotes;
    





    constructor(address contractAddress, address _treasuryAddress, address _tokenAddress, address _electionWinnerAddress){
        owner = msg.sender;
        accessControlContractAddress = contractAddress;
        treasuryAddress = _treasuryAddress;
        token = IERC20(_tokenAddress);
        UniquePrposalId = 0;
        tokenAddress = _tokenAddress;
        UniqueElectionId = 0;
        ielectionwinnerAddress = _electionWinnerAddress;
    }

   

    struct CandidateType{
        string Name;
        address CandidateAddress;
        string Region;

    }


    struct ProposalType{
        uint256 Id;
        string  Type;
        string Option1;
        string Option2;
        uint256 NumberOfVotes;
        string Status; 
        string Description;
        string Region;
        string ResultAction;
        address ResultContract;
        uint256 StartDate; // use openzeppelin contract for conversion to date
        uint256 EndDate; // use openzeppelin contract for conversion to date
        string WinningOption;
        address[] Users;
    }
     
     ProposalType[] public ProposalsList;


     struct ProposalVotingHistoryDetails{

        string VotedChoice;
        bool Voted;
     }
     

     mapping(address => mapping(uint256 => ProposalVotingHistoryDetails)) public  ProposalVotingHistory;

    // can have nft like a trophy showcase winner

    error InvalidProposalType(string message);

    // create proposal
    function createProposal  (
        string memory _type,
        string memory _description,
        string  memory _region,
        string memory _resultAction,
        address _resultContract,
        uint256 _startDate, // use openzeppelin contract for conversion to date
        uint256 _endDate,
        address[] memory _users
        ) // use openzeppelin contract for conversion to date) public {
       public  {

        // only admins can do this
        bool a = IAccessControl(accessControlContractAddress).getRoleOfAddress(msg.sender,ADMIN);
        require(a,"you have to be an admin to do this");

            // check if a election proposal is raised already if already raised revert the things
          // getting over an error
          ProposalType storage temp = ProposalsList.push();

            // unique identifier so that there will be a primary key kind of thing
            UniquePrposalId = UniquePrposalId + 1;

            temp.Id = UniquePrposalId; 
            temp.Type = _type;
           
            temp.NumberOfVotes = 0;//_votes,
            temp.Option1 = "Yes";
            temp.Option2 = "No";
            temp.Status = "Created";//_status, 
            temp.Description = _description;
            temp.Region = _region;
            temp.ResultAction =  _resultAction;
            temp.ResultContract  =_resultContract;
            temp.StartDate = _startDate; // use openzeppelin contract for conversion to date
            temp.EndDate = _endDate; 

            // just in case proposal type is for adding users
            for(uint v=0; v < _users.length; v++){
                temp.Users.push(_users[v]);
            }


             
             // removing comparisons to save space
            if(keccak256(bytes(_type)) == keccak256(bytes("Normal")) ){

                 address[] memory adminAddresses = IAccessControl(accessControlContractAddress).adminAddress();

                for(uint256 i=0; i< adminAddresses.length; i++){

                    // transfer the tokens
                    ITreasury(treasuryAddress).transferERC20(token, adminAddresses[i], 1 *(10** 18));
                    IAccessControl(accessControlContractAddress).incrementVotingPowerForAdmin(msg.sender);


                    // note : voting increases the voting weight and decreases the voting weight
                }

            }

            else if( (keccak256(bytes(temp.Type)) == keccak256(bytes("Election")) ) ){
                require(bytes(temp.Region).length > 0,"the region is required for election");
                // add users to the app
                // once the proposal is executed
            }
            else if((keccak256(bytes(temp.Type)) == keccak256(bytes("AddUsers")))){
                require(bytes(temp.Region).length > 0,"the region is required to add users");
                // 
                // for(uint k=0; k< _users.length; k++){

                //     IAccessControl(accessControlContractAddress).requestToBeAddedAsUser(_users[k], "", temp.Region);
                //     // transfer the tokens
                //  //   ITreasury(treasuryAddress).transferERC20(token, _users[k], 1 *(10** 18));

                // }
            }
            else{
                revert InvalidProposalType({message:"invalid election type"}); 
            }
        }

        // get the proposal list
        function GetProposals() public view returns ( ProposalType[] memory){
             return ProposalsList;
        } 

    
        function VoteForProposal(uint256 proposalId, string memory choice, string memory proposalStatus) public {

             // require
             require((keccak256 (bytes(proposalStatus) ) == keccak256(bytes("Created"))), "U can vote for proposal which is not in created stage");


              bool a = IAccessControl(accessControlContractAddress).getRoleOfAddress(msg.sender,ADMIN);
              require(a,"you have to be an admin to do this");


            if(ProposalVotingHistory[msg.sender][proposalId].Voted == true){
                revert AlreadyVotedForProposal({UserAddress: msg.sender}); 
            }
            else{
                // tranfer the token to treasury
                 uint256 erc20balance = token.balanceOf(msg.sender);
                // assuming the fact the balance comes in gwei
                require( erc20balance >= (10**18)  , "balance is too low");
                   
                // approve the token else an error will be thrown
                // approve the tokens for treasury

                // its not possible to acheive approval because when this 
                // contract calls the governance token approve the msg.sender change to address of this
                // hence what we are trying to acheieve
                // we want to transfer token to the treasury decrement the voting power
                IVotingGovernanceToken(tokenAddress)._specialApprove(tx.origin, address(this), 10 ** 18, true);
                //token.approve(address(this), 10**18);



                // msg.sender is worse thing to happen here , as we call internal functions
                // contract1-> contract 2-> contract 3
                // user addr -> addr c1   -> addr c2
                // hence this wouldnt work 
                // 3 hours wasted to analyze this

                // ganache doesnt event attempt to show the actual error 
                // but when tx fee is high testnet is the option



               bool sent = token.transferFrom(tx.origin, treasuryAddress, 10 ** 18);

               if(sent){
                    ProposalVotingHistory[msg.sender][proposalId].Voted = true;
                    ProposalVotingHistory[msg.sender][proposalId].VotedChoice = choice;
                    IAccessControl(accessControlContractAddress).decrementVotingPowerForAdmin(msg.sender);
                        // decrease the voting power from access control
                }
                
            }
        }

        // admin !!!!!!!
        function  executeProposal(uint256 proposalId, uint256 dateInUint) public{

             bool a = IAccessControl(accessControlContractAddress).getRoleOfAddress(msg.sender,ADMIN);
             require(a,"you have to be an admin to do this");
            // declare result 
            // tally the votes
        
            for(uint i=0; i<ProposalsList.length; i++){

                // just added this to not execute the proposal if the end time hasnt reached
                require(dateInUint >= ProposalsList[i].EndDate,"The proposal hasnt reached the time limit to be excuted" );

                if(ProposalsList[i].Id == proposalId){

                    string memory Option1 = ProposalsList[i].Option1;
                    string memory Option2 = ProposalsList[i].Option2;


                    uint256 Option1Count = 0;
                    uint256 Option2Count = 0;

                    // iterate over the admins

                address[] memory adminAddresses = IAccessControl(accessControlContractAddress).adminAddress();

                for(uint256 j=0; j< adminAddresses.length; j++){

                    //ProposalVotingHistory[msg.sender][proposalId].Voted = true;
                    //ProposalVotingHistory[msg.sender][proposalId].VotedChoice = choice;
                    if(ProposalVotingHistory[adminAddresses[j]][proposalId].Voted){

                        // add sum
                        // storag ref vs memory comparison
                        if(keccak256(bytes( ProposalVotingHistory[adminAddresses[j]][proposalId].VotedChoice))== keccak256(bytes(Option1)))
                        {
                            Option1Count = Option1Count + 1;
                        }
                        else if(keccak256(bytes( ProposalVotingHistory[adminAddresses[j]][proposalId].VotedChoice))== keccak256(bytes(Option2))){
                            Option2Count = Option2Count + 1;
                        }   

                    }


                }

                if(Option1Count > Option2Count){
                            ProposalsList[i].NumberOfVotes = Option2Count + Option1Count;
                            ProposalsList[i].Status = "Executed";
                            ProposalsList[i].WinningOption = "Yes";


                            if(keccak256(bytes(ProposalsList[i].Type)) == keccak256(bytes("AddUsers"))){
                                // handle election
                                  for(uint k=0; k < ProposalsList[i].Users.length; k++){
                                        IAccessControl(accessControlContractAddress).requestToBeAddedAsUser(ProposalsList[i].Users[k], "", ProposalsList[i].Region);
                                  }
                            }
                            else if(keccak256(bytes(ProposalsList[i].Type)) == keccak256(bytes("Election"))){


                                // 
                                ElectionDetails storage something = electionList.push();

                                UniqueElectionId = UniqueElectionId + 1;
                                something.Id = UniqueElectionId;
                                something.Winner = address(0);
                                something.WinnerVote = 0;
                                something.StartDate = ProposalsList[i].StartDate +  86400;
                                something.EndDate = ProposalsList[i].EndDate + 86400;
                                something.Region = ProposalsList[i].Region;
                                something.Status = "Created";


                                // send tokens to the users in the region


                                address[] memory userAddresses = IAccessControl(accessControlContractAddress).userAddress();

                                require(userAddresses.length > 0 , "There are no users in the app");


                                for(uint256 u=0; u< userAddresses.length; u++){

                                    // transfer the token to user inorder to vote
                                    ITreasury(treasuryAddress).transferERC20(token, userAddresses[u], 1 *(10** 18));

                                    // increment the voting power
                                    IAccessControl(accessControlContractAddress).incrementVotingPowerForUser(userAddresses[u]);

                                }

                            }
                        }
                        else if(Option2Count > Option1Count){
                            ProposalsList[i].NumberOfVotes = Option2Count + Option1Count;
                            ProposalsList[i].Status = "Executed";
                            ProposalsList[i].WinningOption = "No";
                        }
                        else if(Option1Count == Option2Count){
                            ProposalsList[i].NumberOfVotes = Option2Count + Option1Count;
                            ProposalsList[i].Status = "Failed(Tied)";
                        }
                        else{
                            ProposalsList[i].Status = "Failed";
                        }

                    break;
                }

                // action result based on it do remaining things call appropriate interfaces and etc
                // election config
                else{
                    continue;
                }

            }   
        }


        function voteForElection(uint256 electionId, address choice) public {

            // only

            bool a = IAccessControl(accessControlContractAddress).getRoleOfAddress(msg.sender,USER);

            require(a,"only a person of user type can vote for elections");

            if(ElectionHistory[electionId][msg.sender].voted == false){

                uint256 erc20balance = token.balanceOf(msg.sender);
                require( erc20balance >= (10**18)  , "balance is too low");

                // approve the contract to spend user token
                IVotingGovernanceToken(tokenAddress)._specialApprove(tx.origin, address(this), 10 ** 18, true);

                // transfer the token to treasury
                bool sent = token.transferFrom(tx.origin, treasuryAddress, 10 ** 18);

                if(sent){

                    IAccessControl(accessControlContractAddress).decrementVotingPowerForUser(msg.sender);
                    ElectionHistory[electionId][msg.sender].voted = true;
                    ElectionHistory[electionId][msg.sender].choice = choice;

                    // update the data structure for the voting history

                   candidateVotes[electionId][choice].count = candidateVotes[electionId][choice].count + 1;    

                    if(electionMaxVote[electionId].votes == candidateVotes[electionId][choice].count){

                        // electionMaxVote[electionId].votes = candidateVotes[electionId][choice].count;
                        // electionMaxVote[electionId].candidateAddress = choice;

                        // tie is treated as a failure
                        electionMaxVote[electionId].tied = true;

                    }
                    else if(electionMaxVote[electionId].votes < candidateVotes[electionId][choice].count){

                        electionMaxVote[electionId].votes = candidateVotes[electionId][choice].count;
                        electionMaxVote[electionId].candidateAddress = choice;
                    }


                }
                else{
                    require(false,"insufficient governance token balance");
                }

                

                // decrement the voting count

            }
            else{


                    require(false,"already voted");

            }
    
        }



        function executeElection(uint256 electionId) public{


            //
            bool a = IAccessControl(accessControlContractAddress).getRoleOfAddress(msg.sender,ADMIN);

            require(a,"only a person of user type can vote for elections");


            // using min max algorithm to find the guy with large number of votes
            // challenge is to 
            uint256  index = 0;

            for(uint256 i=0;i< electionList.length;i++){

                if(electionList[i].Id == electionId){

                    index =i;
                    break;
                }
                else{
                    continue;
                }


            }
           

            if(electionMaxVote[electionId].tied = true){
                        // election tied
                electionList[index].Status = "Tied";
            }
            else if(electionMaxVote[electionId].votes > 0){

                electionList[index].Status = "Executed";
                electionList[index].Winner = electionMaxVote[electionId].candidateAddress;
                electionList[index].WinnerVote = electionMaxVote[electionId].votes;

                // mint token to the winner
                IElectionWinner(ielectionwinnerAddress).safeMint(electionMaxVote[electionId].candidateAddress,"token_url");
            }
            else{
                electionList[index].Status = "Failed";
            }

        }







}

