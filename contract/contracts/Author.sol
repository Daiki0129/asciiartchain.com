pragma solidity ^0.5.10;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract Author is Ownable {
    using SafeMath for uint256;

    uint public initialAuthorFee = 0.00001 ether;

    mapping(uint => address payable) public tokenToAuthor;
    mapping(uint => uint) public paymentToAuthor;
    // mapping(address => uint[]) public authorToTokenList;

    modifier onlyTokenAuthor(uint _tokenId) {
        require(msg.sender == tokenToAuthor[_tokenId]);
        _;
    }

    function authorOf(uint _tokenId) external view returns (bool){
        if(tokenToAuthor[_tokenId] == msg.sender) return true;
        return false;
    }
    /* setting functions */
    function changeAuthorFee(uint _tokenId, uint _authorFee) public onlyTokenAuthor(_tokenId) returns (bool){
        require(0.01 ether >= _authorFee);
        paymentToAuthor[_tokenId] = _authorFee;
        return true;
    }

    function settingOfAuthorFee(uint _tokenId) internal returns (bool){
        tokenToAuthor[_tokenId] = msg.sender;
        paymentToAuthor[_tokenId] = initialAuthorFee;
        // authorToTokenList[msg.sender].push(_tokenId);
        return true;
    }

    /* payment functions */
    function paymentOnlyAuthorFee(uint _tokenId) public payable returns (bool){
        require(msg.value == paymentToAuthor[_tokenId]);
        tokenToAuthor[_tokenId].transfer(paymentToAuthor[_tokenId]);
        return true;
    }
}