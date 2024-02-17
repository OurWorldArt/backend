// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DeployedOurWorldArt} from "../script/DeployedOurWorldArt.s.sol";
import {OurWorldArt} from "../src/OurWorldArt.sol";

contract OurWorldArtTest is Test {
    OurWorldArt public ourWorldArt;
    DeployedOurWorldArt public deployer;

    uint24[] public flatMatrix;
    uint256 rows = 10;
    uint256 columns = 10;

    address public bob = makeAddr("bob");
   
    function setUp() public {
        deployer = new DeployedOurWorldArt();
        ourWorldArt = deployer.run();
    }

    function testCreateMatrix() public {
        ourWorldArt.createMatrix(rows, columns);
        assertEq(rows, ourWorldArt.rows());
        assertEq(columns, ourWorldArt.columns());
        flatMatrix = ourWorldArt.getMatrix();
        assertTrue(ourWorldArt.matrixExists());
        assertFalse(ourWorldArt.matrixMinted());
        assertTrue(ourWorldArt.matrixExists());
    }
    function testMintMatrix() public {
        //Create a matrix
        ourWorldArt.createMatrix(rows, columns);
        //Mint the matrix
        ourWorldArt.safeMint(bob);
        assertTrue(ourWorldArt.matrixMinted());
        assertEq(bob, ourWorldArt.ownerOf(0));
    }
    function testViewTokenURI() public {
        //Create a matrix
        ourWorldArt.createMatrix(rows, columns);
        //Mint the matrix
        ourWorldArt.safeMint(bob);
        //Check the tokenURI
        string memory tokenURI = ourWorldArt.tokenURI(0);
        console.log(tokenURI);
    }
    function testUpdateMatrixCell() public {
        //Create a matrix
        ourWorldArt.createMatrix(rows, columns);
        //Update a cell
        ourWorldArt.updateMatrixCell(0, 0, 0);
        assertEq(0, ourWorldArt.matrix(0,0)); // Pixel 0,0 should be 0 (black)
        ourWorldArt.updateMatrixCell(0, 1, 16711422);
        assertEq(16711422, ourWorldArt.matrix(0,1)); // Pixel 0,1 should be 16711422
    }
}
