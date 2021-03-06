// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TangeloOptions} from "../TangeloOptions.sol";
import {MockERC721} from "../mock/MockERC721.sol";

contract ContractTest is DSTest {
    
    TangeloOptions public option;
    MockERC721 public mock;
    Vm vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        option = new TangeloOptions();
        mock = new MockERC721("Mock", "MK");
        
        mock.mint(address(0x1337), 1);
    }

    function test_depositToken() public {

        vm.startPrank(address(0x1337));
        mock.approve(address(option), 1);
        option.depositToken(address(mock), 1);
        vm.stopPrank();

        assertEq(option.tokenActualOwner(address(mock), 1), address(0x1337));
        assertEq(mock.ownerOf(1), address(option));
    }

    function test_purchaseOption() public {

        vm.startPrank(address(0x1337));
        mock.approve(address(option), 1);
        option.depositToken(address(mock), 1);
        vm.stopPrank();
        
        uint premiumPrice = 1 wei;
        option.puchaseOption{value: premiumPrice}(address(mock), 1);

        assertEq(option.tokenActualOwner(address(mock), 1), address(0x1337));
        assertEq(address(0x1337).balance, premiumPrice);
        assertEq(option.optionBuyerToken(address(mock), 1), address(this));
    }

}
