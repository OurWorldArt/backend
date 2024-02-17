// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/Base64.sol";
import "lib/openzeppelin-contracts/contracts/utils/Strings.sol";

// import {console} from "forge-std/Script.sol";

contract OurWorldArt is ERC721, ERC721URIStorage, Ownable {
    // ================================================================
    // |                          Errors                              |
    // ================================================================

    // ================================================================
    // |                   Type declarations                          |
    // ================================================================

    // ================================================================
    // |                    STATE VARIABLES                           |
    // ================================================================

    //Contract variables
    uint256 private _nextTokenId;
    uint256 public rows;
    uint256 public columns;
    uint24[][] public matrix;
    bool public matrixExists = false; // New flag to check if a matrix has been created
    bool public matrixMinted = true; // Initially true to allow the first matrix to be created

    // ================================================================
    // |                          Events                              |
    // ================================================================

    // ================================================================
    // |                          Functions                           |
    // ================================================================

    constructor(
        address initialOwner
    ) ERC721("OurWorldArt", "OWA") Ownable(initialOwner) {}

    function safeMint(address to) public onlyOwner {
        require(matrixExists, "No matrix exists to mint.");
        matrixMinted = true; // Mark the current matrix as minted
        uint256 tokenId = _nextTokenId++;
        string memory uri = tokenURI(tokenId);
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function createMatrix(uint256 _rows, uint256 _columns) public onlyOwner {
        require(matrixMinted, "The current matrix must be minted before creating a new one.");
        rows = _rows;
        columns = _columns;
        matrix = new uint24[][](_rows);
        for (uint256 i = 0; i < _rows; i++) {
            matrix[i] = new uint24[](_columns);
            for (uint256 j = 0; j < _columns; j++) {
                matrix[i][j] = 16777215; // Initialize with white color
            }
        }
        matrixExists = true;
        matrixMinted = false; // Reset the flag as the new matrix is now pending minting
    }

    // Function to update a matrix cell with a color value
    function updateMatrixCell(
        uint256 x,
        uint256 y,
        uint24 decimalValue
    ) public {
        require(!matrixMinted, "Matrix updates are locked.");
        require(x < rows && y < columns, "Out of bounds."); // Use dynamic matrix size for bounds check
        require(decimalValue >= 0 && decimalValue <= 16777215, "Invalid color value."); // Validate color value
        matrix[x][y] = decimalValue;
    }

    // ================================================================
    // |                          METADATA                            |
    // ================================================================
    // Function to convert the matrix into a string for the tokenURI
    function matrixToString() internal view returns (string memory) {
        string memory matrixString = "[";
        for (uint256 i = 0; i < rows; i++) {
            matrixString = string(abi.encodePacked(matrixString, "["));
            for (uint256 j = 0; j < columns; j++) {
                matrixString = string(
                    abi.encodePacked(
                        matrixString,
                        Strings.toString(matrix[i][j]),
                        j < columns - 1 ? "," : ""
                    )
                );
            }
            matrixString = string(
                abi.encodePacked(matrixString, "]", i < rows - 1 ? "," : "")
            );
        }
        return string(abi.encodePacked(matrixString, "]"));
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        string memory imageURI = ""; // TO DO
        string memory matrixData = matrixToString();
        string memory description = "OurWorldArt NFT";

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "#',
                                Strings.toString(tokenId),
                                '","description":"',
                                description,
                                '", "image":"',
                                imageURI,
                                '","matrix":',
                                matrixData,
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getMatrix() public view returns (uint24[] memory) {
        uint24[] memory flatMatrix = new uint24[](rows * columns);
        uint k = 0;
        for (uint i = 0; i < rows; i++) {
            for (uint j = 0; j < columns; j++) {
                flatMatrix[k++] = matrix[i][j];
            }
        }
        return flatMatrix;
    }
}