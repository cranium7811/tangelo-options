// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";

contract TangeloOptions is ERC721TokenReceiver{


    mapping(address => mapping(uint => address)) public tokenActualOwner;
    mapping(address => mapping(uint => address)) public optionBuyerToken;

    event TokenDeposited(address indexed from, address indexed to, address indexed collectionAddress, uint id);
    event OptionPurchased(address indexed optionBuyer, address indexed tokenOwner, address indexed collectionAddress, uint id);
    event OptionExercised(address indexed optionBuyer, address indexed tokenOwner, address indexed collectionAddress, uint id);
    event OptionClosed(address indexed optionBuyer, address indexed tokenOwner, address indexed collectionAddress, uint id);

    constructor() {}

    modifier optionSeller() {
        _;
    }

    modifier optionBuyer() {
        _;
    }

    /* -------------- Internal Functions -----------------*/

    // calculate dynamic strike price and expiry date
    function _getStrikePrice() internal pure returns(uint) {
        // Dynamic calculation or option seller input?
    }

    function _getExpiryDate() internal pure returns(uint) {
        // Dynamic calculation or option seller input?
    }

    function _getPremiumPrice() internal pure returns(uint) {
        // Dynamic calculation or option seller input?
    }

    function _getFloorPrice() internal pure returns(uint) {
        // Dynamic calculation or option seller input?
    }

    function onERC721Received(address, address, uint, bytes memory) external override pure returns(bytes4) {
        return this.onERC721Received.selector;
    }


    /* ------------- Public functions -------------------*/

    function depositToken(address _collectionAddress, uint _id) public optionSeller {
        ERC721 collectionAddress = ERC721(_collectionAddress);
        require(collectionAddress.ownerOf(_id) == msg.sender, "NOT_OWNER");

        collectionAddress.approve(address(this), _id);

        collectionAddress.safeTransferFrom(msg.sender, address(this), _id);
        
        tokenActualOwner[_collectionAddress][_id] = msg.sender;

        emit TokenDeposited(msg.sender, address(this), _collectionAddress, _id);
    }

    function puchaseOption(address _collectionAddress, uint _id) public {

        address owner = tokenActualOwner[_collectionAddress][_id];

        uint premiumPrice = _getPremiumPrice();

        unchecked {

            // Transfer straight to the seller of the option 
            payable(owner).transfer(premiumPrice);
            
            // option buyer state changes
            optionBuyerToken[_collectionAddress][_id] = msg.sender;

        }

        emit OptionPurchased(msg.sender, owner, _collectionAddress, _id);

    }

    function exerciseTokenAfterExpiry(
        address _collectionAddress, 
        uint _id
    ) public optionBuyer {

        ERC721 collectionAddress = ERC721(_collectionAddress);

        uint strikePrice = _getStrikePrice();
        uint expiryDate = _getExpiryDate();
        uint floorPrice = _getFloorPrice();

        address owner = tokenActualOwner[_collectionAddress][_id];

        require(block.timestamp > expiryDate, "NOT_EXPIRED");
        require(floorPrice >= strikePrice);

        unchecked {
            
            // transfer the floorPrice to the owner of the token
            payable(owner).transfer(floorPrice);

            // transfer the NFT to the option buyer exercising the option
            collectionAddress.safeTransferFrom(owner, msg.sender, _id);

            // option buyer state changes
            optionBuyerToken[_collectionAddress][_id] = address(0);

        }


        emit OptionExercised(msg.sender, owner, _collectionAddress, _id);

    }

    function closeOption(address _collectionAddress, uint _id) public optionSeller {
        uint expiryDate = _getExpiryDate();
        address buyer = optionBuyerToken[_collectionAddress][_id];

        require(block.timestamp > expiryDate);

        optionBuyerToken[_collectionAddress][_id] = address(0);
        
        ERC721(_collectionAddress).safeTransferFrom(address(this), msg.sender, _id);

        emit OptionClosed(buyer, msg.sender, _collectionAddress, _id);
    }


}