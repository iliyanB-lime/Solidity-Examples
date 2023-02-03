// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "./Ownable.sol";

// Create Lottery Contract:

// The contract should have a prize pool
// This contract should also have a list of people or a player pool that represents the people that entered the prize pool
// Those people will enter as they send some amount of ETH. Let’s do it with 0.01 ETH as this will be the required amount to enter.
// At some time, a “Lottery Manager” will pick the winner. Please consider that the “Manager” should only trigger the contract, and the winner should be chosen randomly by the contract itself.
// After the winner is broadcasted, the contract should be reset and it can repeat the action again. Essentially this would be a self-repeated contract that can be used to play any lottery.

contract Lottery is Ownable {
    event LotteryWiner(address winner, uint prize);
    event JoinLottery(address participant, uint amount);

    struct PrizePool {
        uint prize;
        mapping(address => bool) players;
        address payable[] playerAddresses;
    }

    uint public constant MIN_AMOUNT = 10000000000000000;
    uint round = 1;
    mapping(uint => PrizePool) public games;

    function joinGame() external payable {
        require(msg.value >= MIN_AMOUNT, "Please provide at least 0.01 ETH!");
        require(!games[round].players[msg.sender], "This address already join this round!");
        PrizePool storage pool = games[round];
        pool.prize += msg.value;
        pool.playerAddresses.push(payable(msg.sender));
        pool.players[msg.sender] = true;
        emit JoinLottery(msg.sender, msg.value);
    }

    function pickTheWinner() external onlyOwner {
        PrizePool storage pool = games[round];
        require(pool.playerAddresses.length > 0, "No participants!");
        uint randomNum = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, pool.playerAddresses.length)));
        address payable winer = pool.playerAddresses[randomNum % pool.playerAddresses.length];
        winer.transfer(pool.prize);
        emit LotteryWiner(winer, pool.prize);
        round += 1;
    }

    function getRoundPrize(uint _round) external view returns(uint) {
        return games[_round].prize;
    }
}