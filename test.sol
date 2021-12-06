//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ▄████▄   ██▀███ ▓██   ██▓ ██▓███  ▄▄▄█████▓ ▒█████      █     █░ ██░ ██  ▄▄▄       ██▓    ▓█████   ██████ 
// ▒██▀ ▀█  ▓██ ▒ ██▒▒██  ██▒▓██░  ██▒▓  ██▒ ▓▒▒██▒  ██▒   ▓█░ █ ░█░▓██░ ██▒▒████▄    ▓██▒    ▓█   ▀ ▒██    ▒ 
// ▒▓█    ▄ ▓██ ░▄█ ▒ ▒██ ██░▓██░ ██▓▒▒ ▓██░ ▒░▒██░  ██▒   ▒█░ █ ░█ ▒██▀▀██░▒██  ▀█▄  ▒██░    ▒███   ░ ▓██▄   
// ▒▓▓▄ ▄██▒▒██▀▀█▄   ░ ▐██▓░▒██▄█▓▒ ▒░ ▓██▓ ░ ▒██   ██░   ░█░ █ ░█ ░▓█ ░██ ░██▄▄▄▄██ ▒██░    ▒▓█  ▄   ▒   ██▒
// ▒ ▓███▀ ░░██▓ ▒██▒ ░ ██▒▓░▒██▒ ░  ░  ▒██▒ ░ ░ ████▓▒░   ░░██▒██▓ ░▓█▒░██▓ ▓█   ▓██▒░██████▒░▒████▒▒██████▒▒
// ░ ░▒ ▒  ░░ ▒▓ ░▒▓░  ██▒▒▒ ▒▓▒░ ░  ░  ▒ ░░   ░ ▒░▒░▒░    ░ ▓░▒ ▒   ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░▓  ░░░ ▒░ ░▒ ▒▓▒ ▒ ░
//   ░  ▒     ░▒ ░ ▒░▓██ ░▒░ ░▒ ░         ░      ░ ▒ ▒░      ▒ ░ ░   ▒ ░▒░ ░  ▒   ▒▒ ░░ ░ ▒  ░ ░ ░  ░░ ░▒  ░ ░
// ░          ░░   ░ ▒ ▒ ░░  ░░         ░      ░ ░ ░ ▒       ░   ░   ░  ░░ ░  ░   ▒     ░ ░      ░   ░  ░  ░  
// ░ ░         ░     ░ ░                           ░ ░         ░     ░  ░  ░      ░  ░    ░  ░   ░  ░      ░  
// ░                 ░ ░                                                                                      




import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @dev {ERC721} standart erc-721 token
 */

contract CryptoWhales is Context,  Ownable, ERC721{
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIdTracker;
  string private _baseTokenURI;
  uint256 private _price;
  uint256 public _startDate;
  uint private _max;
  address private _admin;
  mapping(address => bool) public whitelist;
  mapping (uint256 => address ) public minter;

  constructor(string memory name, string memory symbol, string memory baseTokenURI, uint256 mintPrice, uint256 startDate ,uint max, address admin) ERC721(name, symbol) {
      _baseTokenURI = baseTokenURI;
      _startDate = startDate;
      _price = mintPrice;
      _max = max;
      _admin = admin;
  }

  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }


  function setPrice(uint mintPrice) external onlyOwner {
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


  function whitelistAddresses(address[] memory _addresses) public onlyOwner
  {
        for (uint i=0; i<_addresses.length; i++) {
            whitelist[_addresses[i]] = true;

        }
  }
  
  function whitelistMint(uint amount) public payable
  {
    require(_tokenIdTracker.current() + amount <= 500, "CryptoWhales: not enough crypto whales left to mint amount");
    require(whitelist[msg.sender] == true, "CryptoWhales: Not whitelisted");
    require(msg.value == _price*amount, "CryptoWhales: must send correct price");

    for(uint i=0; i < amount; i++){
      _mint(msg.sender, _tokenIdTracker.current());
       minter[_tokenIdTracker.current()] = msg.sender;
      _tokenIdTracker.increment();
      splitBalance(msg.value/amount);

    }
  }

  function initAdminMint(uint amount) public onlyOwner {
    require(_tokenIdTracker.current() + amount <= 8888, "CryptoWhales: not enough crypto whales left to mint amount");

    for(uint i=0; i < amount; i++){
      _mint(msg.sender, _tokenIdTracker.current());
      minter[_tokenIdTracker.current()] = msg.sender;
      _tokenIdTracker.increment();
    }
  }

  function tokenMinter(uint256 tokenId) public view returns(address){
    return minter[tokenId];
  }


  function splitBalance(uint256 amount) private {

      uint256 mintingShare  = amount;
      payable(_admin).transfer(mintingShare);
  }


}
