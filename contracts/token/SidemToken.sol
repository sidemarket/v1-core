// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SidemToken is ERC20 {

    constructor() ERC20("Sidemarket", "SIDEM") {
        _mint(msg.sender, 100_000_000 * 10 ** decimals());
    }

}