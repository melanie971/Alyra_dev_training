pragma solidity ^0.5.12; // A locked version of pragma should be used (remmove the ^: pragma solidity 0.5.12;)

contract Crowdsale {
   using SafeMath for uint256;
 
   address public owner; // the owner of the contract
   address public escrow; // wallet to collect raised ETH
   uint256 public savedBalance = 0; // Total amount raised in ETH
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   function Crowdsale(address _escrow) public {
       owner = tx.origin; //MB: try to avoid tx.origin, thus replace tx.origin by msg.sender and 
       // add address of the specific contract
       escrow = _escrow; //MB - am I missing something here?
   }

  
  // MB: events should be used?
   // function to receive ETH
   function() public { //MB: should be payable and internal? //should not be a function with a name and parameters?: function asynSend(address dest, uint amout) internal payable {}
    // a require() is need to ensure that balances[escrow] is not zero: require(balances[])
       balances[msg.sender] = balances[msg.sender].add(msg.value); //MB should not be put in first of operation to avoid reentrancy attack. 
       savedBalance = savedBalance.add(msg.value);
       escrow.send(msg.value); //avoid the fonction send
   }
  
   // refund investisor
   function withdrawPayments() public{
       address payee = msg.sender;
       uint256 payment = balances[payee];
      //MB: add a require function: require(balances[payee]!= 0);
      //MB: here modify the order: 1- savedBalance.sub, 2-balances[payee]=0, 3-msg.sender.tranfert
       payee.send(payment); //MB: avoid the fonction send(), instead: msg.sender.transfert(payment);
 
       savedBalance = savedBalance.sub(payment); //MB: put this at the end of the fonction, as last line
       balances[payee] = 0; //MB: should be placed before substracting the paiement to avoir reentrancy attack
   }
}