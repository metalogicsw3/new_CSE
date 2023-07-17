// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "operator-filter-registry/src/DefaultOperatorFilterer.sol";  
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./ONFT721A.sol";

interface OpenSea {
    function proxies(address) external view returns (address);
}

contract CyberSyndicate is Ownable, ERC2981, DefaultOperatorFilterer, ONFT721A {

    uint256 public maxSupply = 3333;
    uint256 public costPerNft = 0.070 * 1e18;
    uint256 public nftsForOwner = 50;
    string public metadataFolderIpfsLink;
    string constant baseExtension = ".json";
    uint256 public publicmintActiveTime = 1669568400;


   
    constructor(uint256 _minGasToTransferAndStore, address _lzEndpoint) ONFT721A("CyberSyndicate" , "CSE",_minGasToTransferAndStore, _lzEndpoint) {
        _setDefaultRoyalty(msg.sender, 500); // 5.00 %
    }

   

    // public
    function purchaseTokens(uint256 _mintAmount) public payable {
          require(block.timestamp > publicmintActiveTime, "The contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "You have to mint at least 1 NFT");
        require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");
        require(msg.value >= costPerNft * _mintAmount, "Insufficient funds");
        _safeMint(msg.sender, _mintAmount);
    }

    function sendPreMintedNFT(address[] memory  adds) public onlyOwner {
        uint256 addsLen = adds.length;
        uint256 supply = totalSupply();
        require(supply + addsLen <= maxSupply, "Max NFT limit exceeded");
        for (uint256 i = 0; i < addsLen; i++) {
            _safeMint(adds[i], 1);
        }
    }



    function adminMint(address[] calldata _sendNftsTo, uint256 _howMany) external onlyOwner {
        require(nftsForOwner < maxSupply,"Admint mint must be less then the maximum supply");
        require(nftsForOwner > _sendNftsTo.length * _howMany,"Max NFT limit exceeded for owners" );
        nftsForOwner -= _sendNftsTo.length * _howMany;
        for (uint256 i = 0; i < _sendNftsTo.length; i++) _safeMint(_sendNftsTo[i], _howMany);
    }




  
    ///////////////////////////////////
    //       OVERRIDE CODE STARTS    //
    ///////////////////////////////////

    function supportsInterface(bytes4 interfaceId) public view virtual override( ERC2981,ONFT721A) returns (bool) {
        return  interfaceId == type(IERC2981).interfaceId 
        || super.supportsInterface(interfaceId);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return metadataFolderIpfsLink;
    }


    //////////////////
    //  ONLY OWNER  //
    //////////////////

    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance}("");
        require(success);
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
        override(ERC721A, IERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        payable
        virtual
        override(ERC721A, IERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable virtual override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}

