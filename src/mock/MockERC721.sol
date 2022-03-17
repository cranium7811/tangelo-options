// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract MockERC721 is ERC721{

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint id) public {
        _mint(to, id);
    }

    function burn(uint id) public {
        _burn(id);
    }
}