
pragma solidity ^0.4.23;


contract Escrow{

  address owner;
  uint public creationTime; //const set by system now
  uint public limit; //const set by admin
  uint public timeDuration; //const set by admin
  uint public valueLimit; //const set by admin
  uint public valueUsed;
  uint public limitUsed;
  uint public timeEnd;
  uint public moneyIn;



  struct Transaction {
    uint value;
    address recipient;
    string description;
    bool sent;
    uint validateCount;
    mapping(address=>bool)validates;
  }

  Transaction[] public transactions;
  mapping(address => bool) public validators;
  uint public validatorsCount;

  modifier restricted(){
    require(msg.sender == owner);
    _;
  }

  modifier isValidator(){
    require(validators[msg.sender]);
    _;
  }


  modifier hasMoney(){
    require(address(this).balance>0);
    _;
  }

  function timeReset()private{
    creationTime = now;
    limitUsed = 0;
    valueUsed = 0;
    timeEnd = creationTime + timeDuration;
  }


  constructor(address _owner, address _validator) public{
    owner = _owner;
    validators[_validator] = true;
    validatorsCount++;
    limit = 3; //initialized 3 withdraw per day
    valueLimit = 10000000000000000000; //initialized 10 eth withdraw limit in wei
    timeDuration = 86400 * 1 seconds; //for 24 hours limit
    timeReset();//initialized reset
  }

 function loadMoney() public restricted payable{
     moneyIn++;
  }

  function createTransaction
  (
    uint value,
    address recipient,
    string description
    )
    public restricted hasMoney {


      Transaction memory newTransaction = Transaction({
        value: value,
        recipient: recipient,
        description: description,
        sent: false,
        validateCount: 0
        });
        transactions.push(newTransaction);
      }

      function approveTransaction(uint index) public hasMoney{
        Transaction storage transaction = transactions[index];
        require(validators[msg.sender]);
        require(!transaction.validates[msg.sender]);

        transaction.validates[msg.sender] = true;
        transaction.validateCount++;
      }

      function finalizeTransaction(uint index) public restricted hasMoney{

        if(now > timeEnd) timeReset();
        if(limitUsed >= limit) revert();

        limitUsed++;
        Transaction storage transaction = transactions[index];

        require(transaction.validateCount > (validatorsCount /2));
        require(!transaction.sent);

        if(valueUsed >= valueLimit) revert(); //cancel function if user exceeds withdraw limit

        valueUsed += transaction.value; //adding current withdraw value to total used in wei

        transaction.recipient.transfer(transaction.value); // in wei
        transaction.sent = true;
      }

      function getBalance() public view returns(uint){
        return address(this).balance;
      }

      function limitReset(uint _limit, uint _valueLimit, uint _timeDuration)public isValidator{
        limit = _limit;
        valueLimit = _valueLimit;
        timeDuration = _timeDuration * 1 seconds;
        timeReset();
      }

      function getConst() public view returns(uint, uint, uint, uint, uint, uint, uint){
        return (
          creationTime,
          limit,
          timeDuration,
          valueLimit,
          valueUsed,
          limitUsed,
          timeEnd
          );
        }

        function() public payable { }

      }
