//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * ULAN INIT MINT VE SHARE !
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract CryptoWhales is Context,  Ownable , AccessControlEnumerable, ERC721Enumerable, ERC721URIStorage{
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIdTracker;
  string private _baseTokenURI;
  uint256 private _price;
  uint256 public _startDate;
  uint private _max;
  address private _admin;
  address private _admin2;

  mapping (uint256 => address ) public minter;

  constructor(string memory name, string memory symbol, string memory baseTokenURI, uint256 mintPrice, uint256 startDate ,uint max, address admin, address admin2) ERC721(name, symbol) {
      _baseTokenURI = baseTokenURI;
      _startDate = startDate;
      _price = mintPrice;
      _max = max;
      _admin = admin;
      _admin2 = admin2;

      _setupRole(DEFAULT_ADMIN_ROLE, admin);
  }

  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CryptoWhales: must have admin role to change base URI");
    _baseTokenURI = baseURI;
  }

  function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CryptoWhales: must have admin role to change token URI");
    _setTokenURI(tokenId, _tokenURI);
  }

  function setPrice(uint mintPrice) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CryptoWhales: must have admin role to change price");
    _price = mintPrice;
  }

  function price() public view returns (uint) {
    return _price;
  }

  function mint(uint amount) public payable {
    require(msg.value == _price*amount, "CryptoWhales: must send correct price");
    require(_tokenIdTracker.current() + amount <= _max, "CryptoWhales: not enough crypto whales left to mint amount");
    require(_startDate <= block.timestamp,"CryptoWhales: Sale is not active");
    for(uint i=0; i < amount; i++){
      _mint(msg.sender, _tokenIdTracker.current());
      minter[_tokenIdTracker.current()] = msg.sender;
      _tokenIdTracker.increment();
      splitBalance(msg.value/amount);
    }
  }

  function initAdminMint(uint amount) public payable {
    require(msg.sender == _admin || msg.sender == _admin2, "CryptoWhales: Only admin can call");
    require(_tokenIdTracker.current() + amount <= 2, "CryptoWhales: not enough crypto whales left to mint amount");

    for(uint i=0; i < amount; i++){
      _mint(msg.sender, _tokenIdTracker.current());
      minter[_tokenIdTracker.current()] = msg.sender;
      _tokenIdTracker.increment();
    }
  }

  function tokenMinter(uint256 tokenId) public view returns(address){
    return minter[tokenId];
  }

  function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
    return ERC721URIStorage._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return ERC721URIStorage.tokenURI(tokenId);
  }
  
  /**
    * @dev See {IERC165-supportsInterface}.
    */
  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function splitBalance(uint256 amount) private {

      uint256 mintingShare1  = (amount)*3/4;
      uint256 mintingShare2  = (amount)/4;
      payable(_admin).transfer(mintingShare1);
      payable(_admin2).transfer(mintingShare2);
  }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
  }


}
