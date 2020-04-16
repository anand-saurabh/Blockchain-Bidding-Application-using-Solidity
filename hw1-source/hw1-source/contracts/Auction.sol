pragma solidity ^0.5.0;

contract Auction {
    address payable public beneficiary;

    bool auctionEnded;
    // Current state of the auction. You can create more variables if needed
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Constructor
    constructor() public {
        beneficiary = msg.sender;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {


        // TODO If the bid is not higher than highestBid, send the
        // money back. Use "require"
        require(!auctionEnded, "auction has already ended, you can't place bid anymore");
        require(
            msg.value > highestBid,
            "A higher bid exist, you cannot enter a lower bid"
        );
        require(msg.sender != beneficiary, "beneficiary cannot bid");

        // TODO update state

        // TODO store the previously highest bid in pendingReturns. That bidder
        // will need to trigger withdraw() to get the money back.
        // For example, A bids 5 ETH. Then, B bids 6 ETH and becomes the highest bidder. 
        // Store A and 5 ETH in pendingReturns. 
        // A will need to trigger withdraw() later to get that 5 ETH back.

        // Sending back the money by simply using
        // highestBidder.send(highestBid) is a security risk
        // because it could execute an untrusted contract.
        // It is always safer to let the recipients
        // withdraw their money themselves.
        if(highestBid != 0)
        {
            pendingReturns[highestBidder] = pendingReturns[highestBidder] + highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        //
        uint amount = pendingReturns[msg.sender];
        if(amount > 0)
        {
            // TODO send back the amount in pendingReturns to the sender. Try to avoid the reentrancy attack. Return false if there is an error when sending
            //this takes care of reentrancy attack as we are making endingReturns[msg.sender] = 0, so even if next time this logic is called
            //this bidder will have pending retuns as 0
            pendingReturns[msg.sender] = 0;
            bool isSent = msg.sender.send(amount);
            if(!isSent)
            {

                //if return amount fails, return false and store the pendingReturns
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.

    // another way of handling : instead of using "require" as I have used below, we can also use a scope which lets only beneficiary call this "auction end" function
    function auctionEnd() public {
        // TODO make sure that only the beneficiary can trigger this function. Use "require"
        // the "require" code below makes sure only beneficiary can call this auction End function
        require(msg.sender == beneficiary, "only beneficiary can trigger this function");
        // not allow calling multiple times auction end function once the auction end has been called
        require(!auctionEnded, "auction already ended and money transferred to beneficiary");

        // TODO send money to the beneficiary account. Make sure that it can't call this auctionEnd() multiple times to drain money
        auctionEnded = true;
        beneficiary.transfer(highestBid);
    }
}