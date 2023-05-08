// SPDX-License-identifier : MIT

 pragma solidity 0.8.17;

  import "./buyingcontract.sol";

  contract FoodDAO {
// we declare the addresses
// the "coordinator" is the one in charge of the DAO, sort of. Or the deployer in the instant case
      address payable public BuyingContractAddress;
      address public coordinator;

// we have to declare our variables for timing and decision
      uint public voteEndTime;
      uint public decision;
      bool public ended;

// this variable showcases the balance of the DAO
      uint public DAObalance;

// mapping tracks the balances
      mapping(address => uint) balances;

// we need to structs to pack the details of the voters and proposals
      struct Voter {
      uint weight;
      bool voted;
      address delegate;
      uint vote;
  }

// we declared a new mapping to track the address of voters
      mapping(address => Voter) public voters;

// this struct marks the name of each proposal and the vote counts
      struct Proposal {
      string name;
      uint voteCount;
      }


// we created an array to stack up the proposals
      Proposal[] public proposals;

// we need to initalize a lot of things, which we did in the constructor
    constructor (address payable _BuyingContractAddress, uint _voteTime, string[] memory proposalNames) {
      coordinator = msg.sender;
      BuyingContractAddress = _BuyingContractAddress;

      voteEndTime = block.timestamp + _voteTime;
      voters[coordinator].weight = 1;

      for(uint i = 0; i < proposalNames.length; i++) {
         proposals.push(Proposal ({
             name: proposalNames[i],
             voteCount: 0
         }));
      }
        
      }


    function depositETH() public payable  {
        DAObalance = address(this).balance;

        require(block.timestamp >= voteEndTime, "can no longer deposit; the voting has ended");
        require(DAObalance < 1 ether, "the overall balance cannot be more than 1 Ether");

        balances[msg.sender] += msg.value;
   }

   // only the coordinator can approve the voters

   function votingRight(address voter) public {
        require(msg.sender == coordinator, "only the coordinator can approve voters");
        require(!voters[voter].voted, "you have voted already");
        require(voters[voter].weight == 0, "you have not yet been approved as a voter");

        voters[voter].weight = 1;
   }

   function vote(uint proposal) public {
   // initialize the struct
        Voter storage sender = voters[msg.sender];
        
        require(sender.weight != 0, "you have no voting right");
        require(!sender.voted, "you have voted bruh");

        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
   }

   function countVote () public returns (uint winningProposal_) {
        require(block.timestamp > voteEndTime, "you can only count votes when everything has ended");

// declear this variable first because you will need it in the loop
        uint winningVoteCount = 0;

        for(uint p = 0; p < proposals.length; p++) {
            if(proposals[p].voteCount > winningVoteCount){
               winningVoteCount = proposals[p].voteCount;
               winningProposal_ = p;
             }
        }

        decision = winningProposal_;
        ended = true;
   }

   function withdraw (uint amount) public {
       require(balances[msg.sender] >= amount, "you must not have less than the specified amount");

       balances[msg.sender] -= amount;
       payable(msg.sender).transfer(amount);

       DAObalance = address(this).balance;       
   }

   function endVote ()public {
       
       require(block.timestamp > voteEndTime, "cannot call this function because the voting hasn't ended");
       require(ended == true, "you can only end the voting when it has been terminated");
       require(DAObalance >= 1 ether, "you cannot end when you don't have up to 1 ether, c'mon");
       require(decision == 0, "not concluded yet");
     
      if (DAObalance < 1 ether) revert ();

      (bool success, ) = address(BuyingContractAddress).call{value : 1 ether}(abi.encodeWithSignature("FoodProject(uint256)", 1));
      require(success);

      DAObalance = address(this).balance;
   }

   function checkFoodBalance() public view returns (uint) {

       BuyingContract buyingContract = BuyingContract(BuyingContractAddress);
       return buyingContract.foodBalance(address(this));

   }

  }
