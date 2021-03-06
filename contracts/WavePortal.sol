// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    event NewWave(address indexed from, uint256 timestamp, string message);

    uint256 totalWaves;
    uint16 private seed;

    mapping (address => uint) public lastWavedAt;

    struct Wave {
        address waver; //The address of the user who waved.
        string message; //The message the user sent.
        uint256 timestamp; //The timestamp when the user waved.
    }

    Wave[] waves;

    constructor() payable {
        console.log("I AM SMART CONTRACT");
        seed = uint16((block.timestamp + block.difficulty) % 100);
    }

    function wave(string memory _message) public {
        require(lastWavedAt[msg.sender] + 15 minutes < block.timestamp, "Wait 15 minutes");
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s!", msg.sender, _message);
        waves.push(Wave(msg.sender, _message, block.timestamp));

        seed = uint16((block.timestamp + block.difficulty + seed) % 100);
        console.log("Random # generated: %d", seed);

        if(seed <= 50) {
            console.log("%s won!", msg.sender);
            uint prizeAmount = 0.0001 ether;
            require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has");
            (bool success, ) = msg.sender.call{value: prizeAmount}("");
            require (success, "Failed to withdraw money from contract");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() external view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}