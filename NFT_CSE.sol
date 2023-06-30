// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


import "erc721a/contracts/ERC721A.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";  
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./ONFT721ACore.sol";

interface OpenSea {
    function proxies(address) external view returns (address);
}

contract CyberSyndicate is ERC721A("CyberSyndicate", "CSE"), Ownable, ERC2981, DefaultOperatorFilterer, ONFT721ACore {

    uint256 public maxSupply = 5000;
    uint256 public costPerNft = 0.015 * 1e18;
    uint256 public addressLimit = 50;
    mapping(address => uint256) public addressMintedBalance;
    uint256 public nftsForOwner = 50;
    string public metadataFolderIpfsLink;
    uint256 constant presaleSupply = 300;
    string constant baseExtension = ".json";
    uint256 public publicmintActiveTime = 1669568400;
    uint256 public airDropAmount = 100;
    uint256 public airdropCounter = 0;
   
    constructor(uint256 _minGasToTransferAndStore, address _lzEndpoint) ONFT721ACore(_minGasToTransferAndStore, _lzEndpoint) {
        _setDefaultRoyalty(msg.sender, 500); // 5.00 %
    }

    function sendPreMintedNFT(address[] memory  adds) public onlyOwner {
        uint256 addsLen = adds.length;
        for (uint256 i = 0; i < addsLen; i++) {
            addressMintedBalance[adds[i]]++;
            _safeMint(adds[i], 1);
        }
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _tokenId) internal virtual override {
    }

    function _creditTo(uint16, address _toAddress, uint _tokenId) internal virtual override {
    }

    // public
    function purchaseTokens(uint256 _mintAmount) public payable {
          require(block.timestamp > publicmintActiveTime, "The contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "You have to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
        require(msg.value >= costPerNft * _mintAmount, "Insufficient funds");

        for (uint256 i = 1; i <= _mintAmount; i++) {
        addressMintedBalance[msg.sender]++;
        _safeMint(msg.sender, 1);
        }
    }

    function airdrop(address[] calldata _sendNftsTo, uint256 _howMany) external onlyOwner {
        require(airdropCounter +( _howMany * _sendNftsTo.length ) < airDropAmount,"Number have to be less then the airdrop amount");
        airdropCounter += _howMany * _sendNftsTo.length;
        for (uint256 i = 0; i < _sendNftsTo.length; i++) _safeMint(_sendNftsTo[i], _howMany);
    }

    ///////////////////////////////////
    //       OVERRIDE CODE STARTS    //
    ///////////////////////////////////

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981,ONFT721ACore) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }
    function setAirDropAmount(uint256 _amount) public onlyOwner{
        airDropAmount = _amount;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return metadataFolderIpfsLink;
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, _toString(tokenId), baseExtension)) : "";
    }

    //////////////////
    //  ONLY OWNER  //
    //////////////////

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    function giftNft(address[] calldata _sendNftsTo, uint256 _howMany) external onlyOwner {
        nftsForOwner -= _sendNftsTo.length * _howMany;

        for (uint256 i = 0; i < _sendNftsTo.length; i++) _safeMint(_sendNftsTo[i], _howMany);
    }

    function setnftsForOwner(uint256 _newnftsForOwner) public onlyOwner {
        nftsForOwner = _newnftsForOwner;
    }

    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) public onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    function setCostPerNft(uint256 _newCostPerNft) public onlyOwner {
        costPerNft = _newCostPerNft;
    }


    function setMetadataFolderIpfsLink(string memory _newMetadataFolderIpfsLink) public onlyOwner {
        metadataFolderIpfsLink = _newMetadataFolderIpfsLink;
    }

    function setSaleActiveTime(uint256 _publicmintActiveTime) public onlyOwner {
        publicmintActiveTime = _publicmintActiveTime;
    }

    // implementing Operator Filter Registry
    // https://opensea.io/blog/announcements/on-creator-fees
    // https://github.com/ProjectOpenSea/operator-filter-registry#usage

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        virtual
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable virtual override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}

