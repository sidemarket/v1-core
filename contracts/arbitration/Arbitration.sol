// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.9;

contract Arbitration {

    enum ElectionReason {
        TIME,
        IMPEACHMENT,
        RESIGNATION
    }

    address public judgeAddress;
    address public supervisorAddress;

    uint256 public lastElectionTime;
    uint16 public lastElectionNumber;

    // lastElectionNumber => ElectionReason
    mapping(uint16 => ElectionReason) public electionReason;

    mapping(address => bool)[] public judgeCandidates;
    mapping(address => bool)[] public supervisorCandidates;

    bool public isElectionActive;

    modifier onlyNotCandidates {
        require(
            judgeCandidates[lastElectionNumber][msg.sender] == false && supervisorCandidates[lastElectionNumber][msg.sender] == false,
            "You cannot be a candidate"
        );
    }

    modifier onlySupervisor {
        require(msg.sender == supervisorAddress, "You need to be the supervisor");
    }

    modifier onlyJudge {
        require(msg.sender == judgeAddress, "You need to be the judge");
    }

    modifier inElection {
        require(isElectionActive, "You cannot execute this without an election active");
    }

    modifier notElection {
        require(isElectionActive == false, "You cannot execute this with an election active");
    }

    function registerJudgeCandidature() external onlyNotCandidates inElection {
        judgeCandidates[lastElectionNumber][msg.sender] = true;
    }

    function registerSupervisorCandidature() external onlyNotCandidates inElection {
        supervisorCandidates[lastElectionNumber][msg.sender] = true;
    }

    function startElection() external {
        require(block.timestamp > lastElectionTime + 365 days, "An election cannot start until 365 days have passed");

        _startElection();
        electionReason[lastElectionNumber] = ElectionReason.TIME;
    }

    function _startElection() internal notElection {
        isElectionActive = true;
        lastElectionTime = block.timestamp;
        lastElectionNumber++;
    }

    function impeachJudge() external onlySupervisor notElection {
        _startElection();
        electionReason[lastElectionNumber] = ElectionReason.IMPEACHMENT;
    }

    function resignJudge() external onlyJudge notElection {
        _startElection();
        electionReason[lastElectionNumber] = ElectionReason.RESIGNATION;
    }

    function endElection() external inElection {
        require(block.timestamp > lastElectionTime + 7 days, "An election should last at least 7 days");

        isElectionActive = false;
    }

}
