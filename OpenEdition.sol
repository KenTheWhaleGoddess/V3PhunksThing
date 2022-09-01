 // SPDX-License-Identifier: MIT
pragma solidity 0.8.12;


import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./SSTORE2.sol";
import "./Base64.sol";
import "./ICharityProvider.sol";

struct DropDatas {
    uint16 maxPerWallet;
    uint16 maxSupply;
    uint16 charityPercent;
    uint16 royaltyPercent;
    uint256 mintPrice;

    address ownerOf;
    address artRef;
    address nameRef;
    address charity;
    bool isEns;
}

contract OpenEdition is Ownable, ERC1155Supply, ReentrancyGuard {
    uint256 counter;

    bool v3RequirementEnabled = true;
    address v3phunks = 0xb7D405BEE01C70A9577316C1B9C2505F146e8842;
    address charityProvider = 0xDF6e46d6a0999a5c0D19C094A11b9d4A03D9C3F9;

    mapping(address => mapping(uint256 => uint256)) mintedByWalletPerEdition;

    mapping(uint256 => uint256) ethRaisedPerEdition;

    mapping(uint256 => uint256) ethWithdrawn;
    mapping(uint256 => uint256) ethGivenToCharity;
    mapping(address => uint256) charityToEthReceived;

    mapping(uint256 => DropDatas) drops;

    constructor() ERC1155("") {}


    function mint(uint256 tokenId, uint256 amount) external payable nonReentrant {
        require(tokenId < counter, "aaa");
        require(amount + mintedByWalletPerEdition[msg.sender][tokenId] < drops[tokenId].maxPerWallet, "max per wallet per edition");
        require(super.totalSupply(tokenId) + amount < drops[tokenId].maxSupply, "too many");
        require(msg.value >= amount * drops[tokenId].mintPrice, "not sending enough ETH");
        mintedByWalletPerEdition[msg.sender][tokenId] += amount;
        ethRaisedPerEdition[tokenId] += msg.value;
        _mint(msg.sender, tokenId, amount, '');
    }

    function createNewDrop(string memory name, string memory art, uint256 mintPrice,
        uint16 maxPerWallet, uint16 maxSupply, address charity, uint16 charityPercent, uint16 royaltyPercent) external payable nonReentrant {
        require(!v3RequirementEnabled || IERC721(v3phunks).balanceOf(msg.sender) > 0, "need 1 v3 phunk");
        require(ICharityProvider(charityProvider).isCharity(charity), "not considered a charity");
        require(msg.value >= .1 ether, "not senidng enough");
        require(charityProvider != address(0), "charity provider is not set");
        require(charityPercent > 29 && charityPercent < 101, "charity percent is in basis points of 100. we require 30-100% given to charity");
        require(royaltyPercent <= 10, "Artist royalties percent is in basis points of 100 and must be <= 10%");


        (bool success, ) = payable(charity).call{value: msg.value}('');
        require(success, "unable to send value");        

        drops[counter] = DropDatas(
            maxPerWallet,
            maxSupply,
            royaltyPercent,
            charityPercent,
            mintPrice,
            msg.sender,
            SSTORE2.write(bytes(art)),
            SSTORE2.write(bytes(name)),
            charity,
            false
        );
        emit CharitySent(drops[counter].ownerOf, charity, msg.value);

        counter += 1;
    }

    function createNewDropEnsCharity(string memory name, string memory art, uint256 mintPrice,
        uint16 maxPerWallet, uint16 maxSupply, string calldata charity, uint16 charityPercent, uint16 royaltyPercent) external payable nonReentrant {
        require(!v3RequirementEnabled || IERC721(v3phunks).balanceOf(msg.sender) > 0, "need 1 v3 phunk");
        require(ICharityProvider(charityProvider).isEnsCharity(charity), "not considered a charity");
        require(msg.value >= .1 ether, "not senidng enough");
        require(charityProvider != address(0), "charity provider is not set");
        require(charityPercent > 29 && charityPercent < 101, "charity percent is in basis points of 100. we require 30-100% given to charity");
        require(royaltyPercent <= 10, "Artist royalties percent is in basis points of 100 and must be <= 10%");


        (bool success, ) = payable(ICharityProvider(charityProvider).resolveCharityEns(charity)).call{value: msg.value}('');
        require(success, "unable to send value");        
        drops[counter] = DropDatas(
            maxPerWallet,
            maxSupply,
            royaltyPercent,
            charityPercent,
            mintPrice,
            msg.sender,
            SSTORE2.write(bytes(art)),
            SSTORE2.write(bytes(name)),
            SSTORE2.write(bytes(charity)),
            true
        );
        emit CharitySentToEns(drops[counter].ownerOf, charity, msg.value);

        counter += 1;
    }
    function getDropDetails(uint16 idx) external returns (DropDatas memory datas) {
        require(idx < counter, "not a valid drop");
        datas = drops[idx];
    }

    function ethRaisedForAllCharities() external view returns (uint256 eth) {
        for(uint i; i < counter; i++) {
            eth += ethGivenToCharity[i];
        }
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


    //anyone can call this function to withdraw funds.


    function withdrawAllFromDropEnsForCharity(uint256 idx) external {
        require(ethRaisedPerEdition[idx] > ethWithdrawn[idx], "balance is 0");
        require(drops[idx].isEns, "this is an ENS donation");
        require(ICharityProvider(charityProvider).isCharity(drops[idx].charity));
        uint256 withdrawable = ethRaisedPerEdition[idx] - ethWithdrawn[idx];
        uint256 charitable = withdrawable * drops[idx].charityPercent / 100;

        ethWithdrawn[idx] += withdrawable;
        ethGivenToCharity[idx] += charitable;
        charityToEthReceived[drops[idx].charity] += charitable;
        string memory ens = string(SSTORE2.read((drops[idx].charity)));
        (bool succ, ) = payable(ICharityProvider(charityProvider).resolveCharityEns(ens)).call{value: charitable}('');
        (bool succ2, ) =payable(drops[idx].ownerOf).call{value: withdrawable - charitable}('');
        require(succ && succ2, "something didnt work hmmmm");
        emit CharitySentToEns(drops[idx].ownerOf, ens, charitable);
    }

    function withdrawAllFromDropNoEns(uint256 idx) external {
        require(ethRaisedPerEdition[idx] > ethWithdrawn[idx], "balance is 0");
        require(!drops[idx].isEns, "this is not an ENS donation");
        require(ICharityProvider(charityProvider).isCharity(drops[idx].charity));
        uint256 withdrawable = ethRaisedPerEdition[idx] - ethWithdrawn[idx];
        uint256 charitable = withdrawable * drops[idx].charityPercent / 100;

        ethWithdrawn[idx] += withdrawable;
        ethGivenToCharity[idx] += charitable;
        charityToEthReceived[drops[idx].charity] += charitable;

        (bool succ, ) = payable(drops[idx].charity).call{value: charitable}('');
        (bool succ2, ) =payable(drops[idx].ownerOf).call{value: withdrawable - charitable}('');
        require(succ && succ2, "something didnt work hmmmm");
        emit CharitySent(drops[idx].ownerOf, drops[idx].charity, charitable);

    }

    //drop owner functions ("super owner" can execute any of this)


    modifier onlyOwnerOfDrop(uint256 idx) {
        require(drops[idx].ownerOf == msg.sender || owner() == msg.sender, "not the drop owner");
        _;
    }


    function setArt(uint256 idx,string memory newArt) external onlyOwnerOfDrop(idx) {
        drops[idx].artRef = SSTORE2.write(bytes(newArt));
    }
    function setName(uint256 idx, string memory newArt) external onlyOwnerOfDrop(idx) {
        drops[idx].nameRef = SSTORE2.write(bytes(newArt));
    }
    function setMintPrice(uint256 idx, uint256 newMintPrice) external onlyOwnerOfDrop(idx) {
        drops[idx].mintPrice = newMintPrice;
    }

    function setMaxPerWallet(uint256 idx, uint16 newMaxPerWallet) external onlyOwnerOfDrop(idx) {
        drops[idx].maxPerWallet = newMaxPerWallet;
    }

    function setCharityNoEns(uint256 idx, address newCharity) external onlyOwnerOfDrop(idx) {
        require(ICharityProvider(charityProvider).isCharity(newCharity));
        drops[idx].charity = newCharity;
    }
    function setCharityEns(uint256 idx, string calldata newCharity) external onlyOwnerOfDrop(idx) {
        require(ICharityProvider(charityProvider).isEnsCharity(newCharity));
        drops[idx].charity = SSTORE2.write(bytes(newCharity));
    }
    function setOwnerOf(uint256 idx, address newOwnerOf) external onlyOwnerOfDrop(idx) {
        drops[idx].ownerOf = newOwnerOf;
    }
    function setMaxSupply(uint256 idx, uint16 newMaxSupply) external onlyOwnerOfDrop(idx) {
        require(super.totalSupply(idx) <= newMaxSupply, "rugged");
        drops[idx].maxSupply = newMaxSupply;
    }
    function setCharityPercent(uint256 idx, uint16 newCharityPercent) external onlyOwnerOfDrop(idx) {
        require(newCharityPercent > 29 && newCharityPercent <= 101, "percent is in basis points of 100");
        drops[idx].charityPercent = newCharityPercent;
    }
    function setRoyaltyPercent(uint256 idx, uint16 newRoyaltyPercent) external onlyOwnerOfDrop(idx) {
        require(newRoyaltyPercent <= 10, "Artist royalties percent is in basis points of 100 and must be > 30%");
        drops[idx].royaltyPercent = newRoyaltyPercent;
    }

    //owner owner functions

    function setV3Requirement(bool _isEnabled) external onlyOwner {
        v3RequirementEnabled = _isEnabled;
    }
    function setV3ContractAddress(address _v3Address) external onlyOwner {
        v3phunks = _v3Address;
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
        return (drops[_tokenId].ownerOf, _salePrice * drops[_tokenId].royaltyPercent / 100);
    }

    event CharitySentToEns(address from, string to, uint256 value);
    event CharitySent(address from, address to, uint256 value);
} 
