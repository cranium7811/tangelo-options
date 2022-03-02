// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import {TangeloOptions} from "../TangeloOptions.sol";
import {MockERC721} from "../mock/MockERC721.sol";

interface CheatCodes {
  function startPrank(address) external;
  function stopPrank() external;
}

contract ContractTest is DSTest {
    
    TangeloOptions public option;
    MockERC721 public mock;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        // cheats.prank(address(0xBEEF));
        option = new TangeloOptions();
        mock = new MockERC721("Mock", "MK");
    }

}
