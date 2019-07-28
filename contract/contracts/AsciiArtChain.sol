pragma solidity ^0.5.10;
//関数の実行の最後につけていく
import "./Strings.sol";
import "./Author.sol";
import "./author_contracts/math/SafeMath.sol";
import "./author_contracts/token/ERC721/ERC721Full.sol";
import "./author_contracts/token/ERC721/ERC721Holder.sol";
import "./author_contracts/ownership/Ownable.sol";

contract AsciiArtChain is ERC721Full, ERC721Holder {
    using Strings for string;
    using Integers for uint;

    function AsciiArtChain () ERC721Full("AsciiArtChain" ,"ART") public {

    }

    struct AsciiArt {
        string ipfsHash;
        address publisher;
    }

    AsciiArt[] public asciiArts;
    mapping (string => uint) ipfsHashToTokenId;

    mapping (address => uint) internal publishedTokensCount;
    mapping (address => uint[]) internal publishedTokens;

    mapping(address => mapping (uint => uint)) internal publishedTokensIndex;

    struct SellingItem {
        address seller;
        uint price;
    }

    mapping (uint => SellingItem) public tokenIdToSellingItem;

    uint public createAsciiArtFee = 0.002 ether;
    uint public publisherCut = 500;
    string preUri1 = "http://api.asciiartChain.com/tokens?tokenId=";
    string preUri2 = "&ipfsHash=";

    /*** Modifier ***/
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /*** Owner Action ***/
    function withdraw() public onlyOwner {
        owner.transfer(this.balance);
    }

    function setCreateAsciiArtFee(uint _fee) public onlyOwner {
        createAsciiArtFee = _fee;
    }

    function setPublisherCut(uint _cut) public onlyOwner {
        require(_cut > 0 && _cut < 10000);
        publisherCut = _cut;
    }

    function setPreUri1(string _preUri) public onlyOwner {
        preUri1 = _preUri;
    }

    function setPreUri2(string _preUri) public onlyOwner {
        preUri2 = _preUri;
    }

    function getIpfsHashToTokenId(string _string) public view returns (uint){
        return ipfsHashToTokenId[_string];
    }

    function getOwnedTokens(address _owner) public view returns (uint[]) {
        return ownedTokens[_owner];
    }

    function getAllTokens() public view returns (uint[]) {
        return allTokens;
    }

    function publishedCountOf(address _publisher) public view returns (uint) {
        return publishedTokensCount[_publisher];
    }

    function publishedTokenOfOwnerByIndex(address _publisher, uint _index) public view returns (uint) {
        require(_index < publishedCountOf(_publisher));
        return publishedTokens[_publisher][_index];
    }

    function getPublishedTokens(address _publisher) public view returns (uint[]) {
        return publishedTokens[_publisher];
    }

    function mintAsciiArt(string _ipfsHash) public payable {
        require(msg.value == createAsciiArtFee);
        require(ipfsHashToTokenId[_ipfsHash] == 0);

        AsciiArt memory _digitalArt = AsciiArt({ipfsHash: _ipfsHash, publisher: msg.sender});
        uint newAsciiArtId = asciiArts.push(_digitalArt) - 1;
        ipfsHashToTokenId[_ipfsHash] = newAsciiArtId;
        _mint(msg.sender, newAsciiArtId);

        publishedTokensCount[msg.sender]++;
        uint length = publishedTokens[msg.sender].length;
        publishedTokens[msg.sender].push(newAsciiArtId);
        publishedTokensIndex[msg.sender][newAsciiArtId] = length;
    }

    function tokenURI(uint _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return preUri1.concat(_tokenId.toString()).concat(preUri2).concat(asciiArts[_tokenId].ipfsHash);
    }

    function addAsciiArtSellingItem(uint _tokenId, uint _price) public onlyOwnerOf(_tokenId) {
        require(tokenIdToSellingItem[_tokenId].seller == address(0));
        SellingItem memory _sellingItem = SellingItem(msg.sender, uint128(_price));
        tokenIdToSellingItem[_tokenId] = _sellingItem;
        approve(address(this), _tokenId);
        safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    function cancelAsciiArtSellingItem(uint _tokenId) public {
        require(tokenIdToSellingItem[_tokenId].seller == msg.sender);
        this.safeTransferFrom(address(this), tokenIdToSellingItem[_tokenId].seller, _tokenId);
        delete tokenIdToSellingItem[_tokenId];
    }

    function purchaseAsciiArtSellingItem(uint _tokenId) public payable {
        require(tokenIdToSellingItem[_tokenId].seller != address(0));
        require(tokenIdToSellingItem[_tokenId].seller != msg.sender);
        require(tokenIdToSellingItem[_tokenId].price == msg.value);

        SellingItem memory sellingItem = tokenIdToSellingItem[_tokenId];

        if (sellingItem.price > 0) {
            uint actualPublisherCut = _computePublisherCut(sellingItem.price);
            uint proceeds = sellingItem.price - actualPublisherCut;
            sellingItem.seller.transfer(proceeds);
            asciiArts[_tokenId].publisher.transfer(actualPublisherCut);
        }

        delete tokenIdToSellingItem[_tokenId];
        this.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    /*** Tools ***/
    function _computePublisherCut(uint _price) internal view returns (uint) {
        return _price * publisherCut / 10000;
    }

}
