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
    uint public constant MATRIX_SIZE = 50;
    uint24[MATRIX_SIZE][MATRIX_SIZE] public matrix; // Use uint24 to store HEX color values (Put it public or private ?)
    bool public matrixFinalized = false; // Status to check for matrix updates

    // ================================================================
    // |                          Events                              |
    // ================================================================

    // ================================================================
    // |                          Modifiers                           |
    // ================================================================

    // ================================================================
    // |                          Functions                           |
    // ================================================================

    constructor(address initialOwner)
        ERC721("OurWorldArt", "OWA")
        Ownable(initialOwner)
    {}

    function safeMint(address to, string memory uri) public onlyOwner {
        require(!matrixFinalized, "Matrix already minted.");
        matrixFinalized = true; // Prevents any future modification of the matrix
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri); 
    }

    // Function to update a matrix cell with a color value
    function updateMatrixCell(uint x, uint y, uint24 hexValue) public {
        require(!matrixFinalized, "Matrix updates are locked."); // Checks if the matrix is locked
        require(x < MATRIX_SIZE && y < MATRIX_SIZE, "Out of bounds");
        matrix[x][y] = hexValue;
    }

    function resetMatrix() private {
        for(uint i = 0; i < MATRIX_SIZE; i++) {
            for(uint j = 0; j < MATRIX_SIZE; j++) {
                matrix[i][j] = 0; // Resets each cell to the default value
            }
        }
        matrixFinalized = false; // Unlocks the matrix for the next cycle
    }

    // ================================================================
    // |                          METADATA                            |
    // ================================================================
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        string memory imageURI = ""; // TO DO

        return 
           string(
            abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"PixelMatrix":"',
                                matrix, 
                                '", "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function getMatrix() public view returns (uint24[] memory) {
        uint24[] memory flatMatrix = new uint24[](MATRIX_SIZE * MATRIX_SIZE);
        uint k = 0;
        for (uint i = 0; i < MATRIX_SIZE; i++) {
            for (uint j = 0; j < MATRIX_SIZE; j++) {
                flatMatrix[k++] = matrix[i][j];
            }
        }
        return flatMatrix;
    }
}