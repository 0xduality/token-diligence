// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import {Owned} from "@solbase/auth/Owned.sol";
import {ERC20} from "@solbase/tokens/ERC20/ERC20.sol";

contract Token is Owned(tx.origin), ERC20 {
    constructor() ERC20("MyToken", "MT", 18) {
        _mint(msg.sender, 10**24);
    }
}
