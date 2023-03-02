// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.9;

import "./../interfaces/IERC20Minimal.sol";

// Used so I don't have to repeat all over the codebase
contract StablecoinAgent {

    enum Stablecoin {
        USDT,
        USDC,
        BUSD
    }

    mapping(Stablecoin => IERC20Minimal) internal tokens;

    constructor() {
        tokens[Stablecoin.USDT] = IERC20Minimal(0x55d398326f99059fF775485246999027B3197955);
        tokens[Stablecoin.USDC] = IERC20Minimal(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        tokens[Stablecoin.BUSD] = IERC20Minimal(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    }

}