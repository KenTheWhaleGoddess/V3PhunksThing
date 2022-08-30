// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./SSTORE2.sol";
import "./Base64.sol";
import "./ICharityProvider.sol";

struct DropDatas {
    uint16 maxPerWallet;
    uint16 maxSupply;
    uint16 mintPrice;
    uint16 charityPercent;

    address ownerOf;
    address artRef;
    address nameRef;
    address charity;
}

contract OpenEdition is Ownable, ERC1155('') {
    uint256 counter;

    bool v3RequirementEnabled = true;
    address v3phunks = 0xb7D405BEE01C70A9577316C1B9C2505F146e8842;
    address charityProvider = 0xDF6e46d6a0999a5c0D19C094A11b9d4A03D9C3F9;

    mapping(address => mapping(uint256 => uint256)) mintedByWalletPerEdition;
    mapping(uint256 => uint256) currentSupplyPerEdition;

    mapping(uint256 => uint256) ethRaisedPerEdition;

    mapping(uint256 => uint256) ethWithdrawn;
    mapping(uint256 => uint256) ethGivenToCharity;
    mapping(address => uint256) charityToEthReceived;

    mapping(uint256 => DropDatas) drops;


    function mint(uint256 tokenId, uint256 amount) external payable {
        require(tokenId < counter, "aaa");
        require(amount + mintedByWalletPerEdition[msg.sender][tokenId] < drops[tokenId].maxPerWallet, "max per wallet per edition");
        require(currentSupplyPerEdition[tokenId] + amount < drops[tokenId].maxSupply, "too many");
        require(msg.value >= amount * drops[tokenId].mintPrice, "not sending enough ETH");
        mintedByWalletPerEdition[msg.sender][tokenId] += amount;
        currentSupplyPerEdition[tokenId] += amount;
        ethRaisedPerEdition[tokenId] += msg.value;
        _mint(msg.sender, tokenId, amount, '');
    }

    function createNewDrop(string memory name, string memory art, uint16 mintPrice,
        uint16 maxPerWallet, uint16 maxSupply, address charity, uint16 charityPercent) external payable {
        require(!v3RequirementEnabled || IERC721(v3phunks).balanceOf(msg.sender) > 0, "need 1 v3 phunk");
        require(ICharityProvider(charityProvider).isCharity(charity), "not considered a charity");
        require(msg.value >= .1 ether, "not senidng enough");
        require(charityProvider != address(0), "charity provider is not set");
        require(charityPercent <= 100, "charity percent is in basis points of 100");

        payable(charity).call{value: msg.value}('');
        drops[counter] = DropDatas(
            maxPerWallet,
            maxSupply,
            mintPrice,
            charityPercent,
            msg.sender,
            SSTORE2.write(bytes(art)),
            SSTORE2.write(bytes(name)),
            charity
        );

        counter += 1;
    }

    function getDropDetails(uint16 idx) external returns (uint16 maxPerWallet, uint16 maxSupply, uint16 mintPrice,
                                                          uint16 charityPercent,address ownerOf,address artRef, address nameRef,address charity) {
        require(idx < counter, "not a valid drop");
        DropDatas memory drop = drops[idx];
        return (drop.maxPerWallet, drop.maxSupply, drop.mintPrice, drop.charityPercent, drop.ownerOf, drop.artRef, drop.nameRef, drop.charity);
    }

    function ethRaisedForAllCharities() external view returns (uint256) {
        uint eth;
        for(uint i; i < counter; i++) {
            eth += ethGivenToCharity[i];
        }
        return eth;
    }

    function uri(uint256 idx) public view override returns (string memory) {
        require(idx < counter, "out of range");
        return string(abi.encodePacked(
            'data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
                        '{"name":"',SSTORE2.read(drops[idx].nameRef), 
                        '", "description":"', 
                        "This is a Phunky drop for charity",
                        '", "image": "', 
                        SSTORE2.read(drops[idx].artRef),
                        '"}')))));
    }

    //drop owner functions ("super owner" can execute any of this)

    modifier onlyOwnerOfDrop(uint256 idx) {
        require(drops[idx].ownerOf == msg.sender || owner() == msg.sender, "not the drop owner");
        _;
    }

    function withdrawAllFromDrop(uint256 idx) external onlyOwnerOfDrop(idx) {
        require(ethRaisedPerEdition[idx] > ethWithdrawn[idx], "balance is 0");
        uint256 withdrawable = ethRaisedPerEdition[idx] - ethWithdrawn[idx];
        uint256 charitable = withdrawable * 3 / 10;
        payable(drops[idx].charity).call{value: charitable}('');
        payable(drops[idx].ownerOf).call{value: withdrawable - charitable}('');

        ethWithdrawn[idx] += withdrawable;
        ethGivenToCharity[idx] += charitable;
        charityToEthReceived[drops[idx].charity] += charitable;
    }

    function setArt(uint256 idx,string memory newArt) external onlyOwnerOfDrop(idx) {
        drops[idx].artRef = SSTORE2.write(bytes(newArt));
    }
    function setName(uint256 idx, string memory newArt) external onlyOwnerOfDrop(idx) {
        drops[idx].nameRef = SSTORE2.write(bytes(newArt));
    }
    function setMintPrice(uint256 idx, uint16 newMintPrice) external onlyOwnerOfDrop(idx) {
        drops[idx].mintPrice = newMintPrice;
    }

    function setMaxPerWallet(uint256 idx, uint16 newMaxPerWallet) external onlyOwnerOfDrop(idx) {
        drops[idx].maxPerWallet = newMaxPerWallet;
    }

    function setCharity(uint256 idx, address newCharity) external onlyOwnerOfDrop(idx) {
        require(ICharityProvider(charityProvider).isCharity(newCharity));
        drops[idx].charity = newCharity;
    }
    function setOwnerOf(uint256 idx, address newOwnerOf) external onlyOwnerOfDrop(idx) {
        drops[idx].ownerOf = newOwnerOf;
    }
    function setMaxSupply(uint256 idx, uint16 newMaxSupply) external onlyOwnerOfDrop(idx) {
        require(currentSupplyPerEdition[idx] < newMaxSupply, "rugged");
        drops[idx].maxSupply = newMaxSupply;
    }
    function setCharityPercent(uint256 idx, uint16 newCharityPercent) external onlyOwnerOfDrop(idx) {
        require(newCharityPercent >= 30 && newCharityPercent < 100, "percent is in basis points of 100");
        drops[idx].charityPercent = newCharityPercent;
    }

    //owner owner functions

    function setV3Requirement(bool _isEnabled) external onlyOwner {
        v3RequirementEnabled = _isEnabled;
    }
    function setCharityProvider(address _newCharityProvider) external onlyOwner {
        require(ICharityProvider(_newCharityProvider).isCharity(address(0)));//sanity check
        charityProvider = _newCharityProvider;
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        return (drops[_tokenId].ownerOf, _salePrice / 10);
    }
} 
