pragma solidity ^0.5.10;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
// import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract Author is Ownable {
    using SafeMath for uint256;

    uint public initialAuthorFee = 0.00001 ether;
    // uint public minimumRange = 1;
    // uint public maximumRange = 5;
    // uint public totalRange = 10;

    mapping(uint => address payable) public tokenToAuthor;
    mapping(uint => uint) public paymentToAuthor;

    modifier onlyTokenAuthor(uint _tokenId) {
        require(msg.sender == tokenToAuthor[_tokenId]);
        _;
    }

    /* setting functions */
    function changeAuthorFee(uint _tokenId, uint _authorFee) public onlyTokenAuthor(_tokenId) returns (bool){
        require(0.01 ether >= _authorFee);
        paymentToAuthor[_tokenId] = _authorFee;
        return true;
    }

    // function changeMinimumRange(uint _minimumRange) public onlyOwner returns (bool){
    //     require(0 <=_minimumRange);
    //     minimumRange = _minimumRange;
    //     return true;
    // }

    // function changeMaximumRange(uint _maximumRange) public onlyOwner returns (bool){
    //     require(10 >= _maximumRange);
    //     maximumRange = _maximumRange;
    //     return true;
    // }

    // function changeRangePaymentToAuthor(uint _tokenId, uint _paymentToAuthor) public onlyTokenAuthor(_tokenId) returns (bool){
    //     require(minimumRange <= _paymentToAuthor && _paymentToAuthor <= maximumRange);
    //     paymentToAuthor[_tokenId] = _paymentToAuthor;
    //     return true;
    // }

    function settingOfAuthorFee(uint _tokenId) internal returns (bool){
        tokenToAuthor[_tokenId] = msg.sender;
        paymentToAuthor[_tokenId] = initialAuthorFee;
        return true;
    }
    /* payment functions */
    // function paymentOwnerAndAuthorFee(uint _tokenId) internal returns (bool){
    //     require(msg.value == totalFee);
    //     uint _ownerFee = totalRange.sub(paymentToAuthor[_tokenId]);
    //     owner().transfer(totalFee.mul(_ownerFee).div(10));
    //     tokenToAuthor[_tokenId].transfer(totalFee.mul(paymentToAuthor[_tokenId]).div(10));
    //     return true;
    // }

    function paymentOnlyAuthorFee(uint _tokenId) public payable returns (bool){
        require(msg.value == paymentToAuthor[_tokenId]);
        tokenToAuthor[_tokenId].transfer(paymentToAuthor[_tokenId]);
        return true;
    }
}