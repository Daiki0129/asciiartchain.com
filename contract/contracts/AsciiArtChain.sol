pragma solidity ^0.5.10;
//関数の実行の最後につけていく
import "./Author.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Holder.sol";

// import "./author_contracts/ownership/Ownable.sol";

contract AsciiArtChain is ERC721Full, ERC721Holder {
    // using Integers for uint;
    address payable public recipientOwner;
    constructor (address payable _recipientOwner) ERC721Full("AsciiArtChain" ,"ART") public {
        recipientOwner = _recipientOwner;
    }

    uint public createAsciiArtFee = 0.002 ether;

    function transferFrom(address from, address to, uint256 tokenId) public payable{
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transferFrom(from, to, tokenId);
        require(paymentOnlyAuthorFee(tokenId), "ERC721: Failure transfer of Author fee");
    }

    function mintAsciiArt(uint _tokenId) public payable {
        require(msg.value == createAsciiArtFee);
        _mint(msg.sender, _tokenId);
        recipientOwner.transfer(createAsciiArtFee);
    }

    function burnAsciiArt(uint256 tokenId) public payable {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
        require(paymentOnlyAuthorFee(tokenId), "ERC721: Failure transfer of Author fee");
    }

}
