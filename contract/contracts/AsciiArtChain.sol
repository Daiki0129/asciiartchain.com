pragma solidity ^0.5.10;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC721Full.sol";
import "./ERC721Holder.sol";
import "./ERC721Pausable.sol";

contract AsciiArtChain is Ownable, ERC721Full, ERC721Holder, ERC721Pausable {
    using SafeMath for uint;

	string public constant ASCIIARTCHAIN_AUTHOR = "Daiki Kunii";
    uint public createAsciiArtFee = 0.002 ether;
    uint internal nextTokenId = 1;
    uint internal addNumber = 1;
    address payable public recipientOwner;
    string public tokenURIPrefix = "https://www.asciiartchain.net/metadata/";

    constructor () ERC721Full("AsciiArtChain" ,"ART") public {
    }

    event MintAsciiArt(
        bytes32 hash,
        string art,
        string authorName,
        address authorAddress,
        uint tokenId
    );

    struct ArtDetails {
        string art;
        string authorName;
        address authorAddress;
        bytes32 artHash;
        uint timestamp;
    }

    mapping (bytes32 => bool) public mintedAsciiArt;
    mapping (uint => ArtDetails) public asciiArt;

    function setRecipientOwner(address payable _recipientOwner) external onlyOwner {
        recipientOwner = _recipientOwner;
    }

    function setTokenURIPrefix(string calldata _tokenURIPrefix) external onlyOwner {
        tokenURIPrefix = _tokenURIPrefix;
    }

    function setCreateAsciiArtFee(uint _createAsciiArtFee) external onlyOwner {
        createAsciiArtFee = _createAsciiArtFee;
    }

    function tokenURI(uint tokenId) public view returns (string memory) {
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

    function mintAsciiArt(string calldata _art, string calldata _authorName) external payable {
      require(msg.value == createAsciiArtFee, "mintAsciiArt: Insufficient payment");

      bytes32 hash = createArtHash(_art);

      require(!mintedAsciiArt[hash], "mintAsciiArt: This AsciiArt has already been issued");

      uint _tokenId = nextTokenId;
      nextTokenId = nextTokenId.add(addNumber);
      asciiArt[_tokenId] = ArtDetails(_art, _authorName, msg.sender, hash, now);
      mintedAsciiArt[hash] = true;
	    super._mint(msg.sender, _tokenId);
      recipientOwner.transfer(createAsciiArtFee);
      emit MintAsciiArt(hash, _art, _authorName, msg.sender, _tokenId);
    }

    function burnAsciiArt(uint tokenId) external {
      require(asciiArt[tokenId].authorAddress == msg.sender, "ERC721Burnable: burn can only be author");
      require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
      super._burn(tokenId);
    }

	function createArtHash(string memory _art) public pure returns(bytes32){
			return keccak256(
				abi.encodePacked(
					_art
				)
			);
    }

}
