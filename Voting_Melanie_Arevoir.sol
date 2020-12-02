// Voting.sol 
pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable{

	struct Voter {
	  	bool isRegistred;
	  	bool hasVoted;
	  	uint votedProposalId;
	 }

	  struct Proposal {
	  	string description;
	  	uint voteCount;
	  }

  
  	uint winningProposalId;
  	string proposalName;


	mapping(address => Voter) public RegisteredVoters; // Le registre des voteurs
	Proposal[] public proposals; //tableau des propositions


	  
	 //Gestion des différents états d'un vote
	 enum WorkflowStatus {
	  RegisteringVoters,
	  ProposalsRegistrationStarted,
	  ProposalsRegistrationEnded,
	  VotingSessionStarted,
	  VotingSessionEnded,
	  VotesTallied //votes enregistrés comptabilisés
	 }

	 WorkflowStatus public currentWorkflowStatus = WorkflowStatus.RegisteringVoters; //on initilise l'état du workflow

	 modifier inState(WorkflowStatus state) { 
  		require (state == currentWorkflowStatus); 
  		_; 
  	}

	 // Les différents évènements
	 event VoterRegistrered(address voterAddress);
	 event ProposalsRegistrationStarted();
	 event ProposalsRegistrationEnded();
	 event ProposalRegistred (uint proposalId);
	 event VotingSessionStarted();
	 event VotingSessionEnded();
	 event Voted (address voter, uint proposalId);
	 event VotesTallied();
	 event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus); // I don't understand this



  	//Etape 1 - L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum
  	 function addVoterToList(address _address) public onlyOwner inState(WorkflowStatus.RegisteringVoters)
  	 {
	      require(RegisteredVoters[_address].isRegistred != true, "This address is already registred !");
	      RegisteredVoters[_address] = Voter(true, false, 0); 
	      emit VoterRegistrered(_address);
	 }


	 //Etape 2 - L'admin commence la session d'enregistrement des propositions émises par les voteurs
	 function startRegisteringProposal() public onlyOwner inState(WorkflowStatus.RegisteringVoters)
	  {
	  	emit ProposalsRegistrationStarted();
	  	currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
	  }

	 //Etape 3 - Les électeurs inscrits sont autorisés à enregistrer leur propostion
	 uint countProposalId = 0;

	  function addProposal(string memory _description) public inState(WorkflowStatus.ProposalsRegistrationStarted)
		  {
		  	require (RegisteredVoters[msg.sender].isRegistred == true, "You're not registered, you can't submit a proposal"); //to be ckecked
		  	//can a voter submit several proposal? also do we have to check that the proposal does not exits? RegisteredVoters[voter].voted,
		  	proposals.push(Proposal(_description, 0)); //Adding the proposal to the array, only the description since count will be done later
		  	countProposalId ++;
		  	emit ProposalRegistred(countProposalId);
		  }

	//Etape 4 - L'administrateur met fin à la session d'enregistrement des propositions
		function endOfRegisteringProposal() public onlyOwner inState(WorkflowStatus.ProposalsRegistrationStarted)
		{
			currentWorkflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
			emit ProposalsRegistrationEnded();
		}


	// Etape 5 - L'administrateur commence la session de vote
		function startVote() public onlyOwner inState(WorkflowStatus.ProposalsRegistrationEnded)
		{
			currentWorkflowStatus = WorkflowStatus.VotingSessionStarted;
			emit VotingSessionStarted();
		}


	//Etape 6 - Les électeurs inscrits votent pour leur proposition preferee:
	function DoingTheVote (uint proposal_id) public inState(WorkflowStatus.VotingSessionStarted)

	 {
		require (RegisteredVoters[msg.sender].isRegistred == true, "You're not registered, you can't vote");// TO DO
		require (RegisteredVoters[msg.sender].hasVoted == false, "You've already vote for a proposal");
		//also require that proposal_id does exit ?
		proposals[proposal_id].voteCount ++; //pour ajouter le vote ) chaque proposal _ revoir la synthaxe
		RegisteredVoters[msg.sender].votedProposalId = proposal_id ; // issue here I think
		RegisteredVoters[msg.sender].hasVoted = true ;//updating status of the voter

		emit Voted (msg.sender, proposal_id);

	}


	//Etape 7- l'administrateur met fin à la session de vote
	function endVote() public inState(WorkflowStatus.VotingSessionStarted) onlyOwner
		{
			currentWorkflowStatus = WorkflowStatus.VotingSessionEnded;
			emit VotingSessionEnded();
		}

  
    
	//Etape 8- l'administrateur comptabilise les votes et retourne l'id de la proposition qui a gagné
	function TheWinnerIs() public inState(WorkflowStatus.VotingSessionEnded) onlyOwner returns(uint)
		{
			uint winningVoteCount = 0 ;
			for (uint i=0; i <proposals.length; i++) {
				if (proposals[i].voteCount > winningVoteCount) {
					winningVoteCount = proposals[i].voteCount;
					winningProposalId = i;
				
			    }
			}
			
    	currentWorkflowStatus = WorkflowStatus.VotesTallied;
    	emit VotesTallied();
    	return winningProposalId;

		}

    // Etape 9 - 
      function LookAtTheWinningProposal() public inState(WorkflowStatus.VotesTallied) returns (string memory proposalName)
      {
        proposalName = proposals[TheWinnerIs()].description;
        }
    
}
		


    
//       //Going Back to Previous Status
       
//     function GoBackToPreviousStatus() public onlyOwner
// 			{
// 				currentWorkflowStatus -=;
// 				emit WorkflowStatusChange(previousStatus);
// 			}


