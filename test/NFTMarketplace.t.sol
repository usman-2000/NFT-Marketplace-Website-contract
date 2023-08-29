// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract NFTMarketplaceTest is Test{
    Marketplace marketplace;

    function setUp() public{
        marketplace = new Marketplace();
    }

    function testgetListingPrice() public{
        assertEq(marketplace.listingPrice(),0.0025 ether);
    }

    function testCreateNft() public{
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.createNft{value: 0.0025 ether}(1,"token1");
    }

    function testBuyItem() public{
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.createNft{value: 0.0025 ether}(1,"token1");

        vm.deal(address(2),2 ether);
        marketplace.setApprovalForAll(address(marketplace),true);
        vm.prank(address(2));
        marketplace.buyItem{value:1 ether}(1);
        assertEq(marketplace.balanceOf(address(2)),1);
    }

    function testResellItem() public{
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.createNft{value: 0.0025 ether}(1,"token1");

        vm.deal(address(2),2 ether);
        marketplace.setApprovalForAll(address(marketplace),true);
        vm.prank(address(2));
        marketplace.buyItem{value:1 ether}(1);
        assertEq(marketplace.balanceOf(address(2)),1);

        vm.prank(address(2));
        marketplace.reSellItem{value: 0.0025 ether}(1,2);
        assertEq(marketplace.balanceOf(address(2)),0);
    }
}