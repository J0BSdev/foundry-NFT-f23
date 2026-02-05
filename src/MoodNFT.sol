//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNFT is ERC721 {
    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;//string jer URI-jevi su tekstualni,cuva  URI slike

    enum Mood {   // **Zašto enum:** Gas-efikasniji od stringova (HAPPY = 0, SAD = 1)
        // **Proširivost:** Lako dodati nova stanja (npr. EXCITED, CALM)
        HAPPY, 
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;
//**Svrha:** Mapira token ID na njegov mood
// **Zašto mapping:** O(1) pristup, najefikasniji način
// **Struktura:** `tokenId => Mood enum`







    constructor(string memory sadSvg, string memory happySvg) ERC721("MoodNFT", "MN") {
        s_sadSvgImageUri = sadSvg;
        s_happySvgImageUri = happySvg;
        s_tokenCounter = 0;
        //- `sadSvg` - URI slike za tužan mood
//- `happySvg` - URI slike za sretan mood

//**Zašto `string memory`:**
//- `memory` je obavezan za stringove u funkcijama (ne storage)

//**Zašto `ERC721("MoodNFT", "MN")`:**
//- Poziva parent konstruktor s imenom i simbolom kolekcije
//- Mora biti prije tijela konstruktora

//**Inicijalizacija:**
//- Postavlja URI-jeve za oba mood-a
//- Resetira brojač na 0       //(iako je to default vrijednost)
    }












    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";

//**Svrha:** Vraća base64-encoded string za JSON
// **Zašto `pure`:** Ne pristupa state-u, samo vraća konstantnu string
// **Zašto `override`:** Nadjačava ERC721 funkciju (potrebno za ERC721URIStorage)
// **Zašto `data:application/json;base64,`:** Base64-encoded JSON string




    } 

    function mintNFT() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
//**Svrha:** Mintuje novi NFT i postavlja mu mood
// **Zašto `_safeMint`:** Sigurno mintanje (prebacuje na konstruktora)
// **Zašto `s_tokenCounter++`:** Inkrementira brojač nakon mintanja
// **Zašto `s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY`:** Postavlja mood za novi NFT










    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }
        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode( 
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description": "An NFT that reflects the owners mood.", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                            imageURI,
                            '"}'
                        )
                    )
                ),
                "}"
            )
        );
    }
//**Svrha:** Vraća tokenURI za dati tokenId
// **Zašto `view`:** Ne mijenja state, samo čita
// **Zašto `override`:** Nadjačava ERC721 funkciju
// **Zašto `string(abi.encodePacked(...))`:** Konvertuje bytes u string
// **Zašto `Base64.encode(bytes(...))`:** Base64-encodes bytes







}
