pragma solidity ^0.5.10;
//関数の実行の最後につけていく
import "./SafeMath.sol";
import "./Author.sol";
import "./ERC721Full.sol";
import "./ERC721Holder.sol";

// import "./author_contracts/ownership/Ownable.sol";

contract AsciiArtChain is ERC721Full, ERC721Holder {
    using SafeMath for uint128;
    
    address payable public recipientOwner;
    constructor () ERC721Full("AsciiArtChain" ,"ART") public {
    }

    uint public createAsciiArtFee = 0.002 ether;
    uint internal nextTokenId = 1000000000000;
    string public tokenURIPrefix = "https://www.asciiartchain.net/metadata/";
    
    // string public asciiArt;

    // function setAsciiArt(string calldata _asciiArt) external {
    //     asciiArt = _asciiArt;
    // }
    // uint16 public constant ASCIIART_TYPE_OFFSET = 10000;

    function setRecipientOwner(address payable _recipientOwner) external onlyOwner {
        recipientOwner = _recipientOwner;
    }
    
    function setTokenURIPrefix(string calldata _tokenURIPrefix) external onlyOwner {
        tokenURIPrefix = _tokenURIPrefix;
    }
    
    function setCreateAsciiArtFee(uint _createAsciiArtFee) external onlyOwner {
        createAsciiArtFee = _createAsciiArtFee;
    }

    function tokenURI(uint tokenId) external view returns (string memory) {
        bytes32 tokenIdBytes;
        if (tokenId == 0) {
            tokenIdBytes = "0";
        } else {
            uint256 value = tokenId;
            while (value > 0) {
                tokenIdBytes = bytes32(uint256(tokenIdBytes) / (2 ** 8));
                tokenIdBytes |= bytes32(((value % 10) + 48) * 2 ** (8 * 31));
                value /= 10;
            }
        }

        bytes memory prefixBytes = bytes(tokenURIPrefix);
        bytes memory tokenURIBytes = new bytes(prefixBytes.length + tokenIdBytes.length);

        uint8 i;
        uint8 index = 0;
        
        for (i = 0; i < prefixBytes.length; i++) {
            tokenURIBytes[index] = prefixBytes[i];
            index++;
        }
        
        for (i = 0; i < tokenIdBytes.length; i++) {
            tokenURIBytes[index] = tokenIdBytes[i];
            index++;
        }
        
        return string(tokenURIBytes);
    }
    
    function transferFrom(address from, address to, uint tokenId) public payable{
      //solhint-disable-next-line max-line-length
      require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
      super._transferFrom(from, to, tokenId);
    //   require(paymentOnlyAuthorFee(tokenId), "ERC721: Failure transfer of Author fee");
    }
//string calldata _message
    function mintAsciiArt() external payable {
      require(msg.value == createAsciiArtFee);
      uint _tokenId = nextTokenId;
      nextTokenId = nextTokenId.add(1);
      super._mint(msg.sender, _tokenId);
    //   super._setTokenURI(_tokenId, _message);
    //   recipientOwner.transfer(createAsciiArtFee);
    }

    function burnAsciiArt(uint tokenId) external payable {
      //solhint-disable-next-line max-line-length
      require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
      super._burn(tokenId);
    //   require(paymentOnlyAuthorFee(tokenId), "ERC721: Failure transfer of Author fee");
    }
}
