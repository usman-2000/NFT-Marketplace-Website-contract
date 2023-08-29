// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {console,Test} from "forge-std/Test.sol";
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

    function testUpdateListing() public{
        marketplace.updateListingPrice(1);
        assertEq(marketplace.listingPrice(),1);
    }

    // function testWithdraw() public{
    //     vm.deal(address(1),2 ether);
    //     vm.prank(address(1));
    //     marketplace.createNft{value: 0.0025 ether}(1,"token1");

    //     vm.deal(address(2),2 ether);
    //     marketplace.setApprovalForAll(address(marketplace),true);
    //     vm.prank(address(2));
    //     marketplace.buyItem{value:1 ether}(1);
    //     assertEq(marketplace.balanceOf(address(2)),1);

    //     vm.prank(address(2));
    //     marketplace.reSellItem{value: 0.0025 ether}(1,2);
    //     assertEq(marketplace.balanceOf(address(2)),0);

    //     vm.prank(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
    //     marketplace.withdraw();
    //     console.log(marketplace.owner());

        
    // }

    function testCreateMultipleItems() public{
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.createNft{value: 0.0025 ether}(1,"token1");

        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        marketplace.createNft{value: 0.0025 ether}(1,"token2");

        vm.deal(address(3),2 ether);
        vm.prank(address(3));
        marketplace.createNft{value: 0.0025 ether}(1,"token3");

        vm.deal(address(4),2 ether);
        vm.prank(address(4));
        marketplace.createNft{value: 0.0025 ether}(1,"token4");
    }

    function testBuyMultipleItemsFromSameAddress() public{
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.createNft{value: 0.0025 ether}(1,"token1");

        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        marketplace.createNft{value: 0.0025 ether}(1,"token2");

        vm.deal(address(3),2 ether);
        vm.prank(address(3));
        marketplace.createNft{value: 0.0025 ether}(1,"token3");

        vm.deal(address(4),2 ether);
        vm.prank(address(4));
        marketplace.createNft{value: 0.0025 ether}(1,"token4");

        vm.deal(address(6),2 ether);
        marketplace.setApprovalForAll(address(marketplace),true);
        vm.prank(address(6));
        marketplace.buyItem{value:1 ether}(1);
        assertEq(marketplace.balanceOf(address(6)),1);

        vm.deal(address(6),2 ether);
        marketplace.setApprovalForAll(address(marketplace),true);
        vm.prank(address(6));
        marketplace.buyItem{value:1 ether}(2);
        assertEq(marketplace.balanceOf(address(6)),2);

        vm.deal(address(6),2 ether);
        marketplace.setApprovalForAll(address(marketplace),true);
        vm.prank(address(6));
        marketplace.buyItem{value:1 ether}(3);
        assertEq(marketplace.balanceOf(address(6)),3);
    }

    function testResellAndBuyNft() public{
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

        vm.deal(address(3),3 ether);
        vm.prank(address(3));
        marketplace.buyItem{value:2 ether}(1);
        assertEq(marketplace.balanceOf(address(3)),1);
    }
}