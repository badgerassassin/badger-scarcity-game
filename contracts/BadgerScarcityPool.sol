// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IMemeLtd } from "./IMemeLtd.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { BadgerScarcityPoolLib } from "./BadgerScarcityPoolLib.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BadgerScarcityPool is ERC1155Holder {
  using BadgerScarcityPoolLib for *;
  using SafeMath for *;
  IERC20 public bdigg;
  IMemeLtd public memeLtd;
  BadgerScarcityPoolLib.PoolToken[] public tokens;
  constructor(address _bdigg, address _memeLtd, uint256[] memory _tokenIds, uint256[] memory _roots)  {
    require(_tokenIds.length == _roots.length, "tokenIds must be same size as roots");
    for (uint256 i = 0 ; i < _tokenIds.length; i++) {
      tokens.push(BadgerScarcityPoolLib.PoolToken({
        tokenId: _tokenIds[i],
        root: _roots[i]
      }));
    }
    memeLtd = IMemeLtd(_memeLtd);
    bdigg = IERC20(_bdigg);
  }
  function reserve() public view returns (uint256) {
    return bdigg.balanceOf(address(this));
  }
  function _assertMemeLtd() internal view {
    require(msg.sender == address(memeLtd), "can only send MemeLtd tokens");
  }
  function onERC1155BatchReceived(address operator, address /* from */, uint256[] memory ids, uint256[] memory values, bytes memory /* */) public virtual override returns (bytes4) {
    _assertMemeLtd();
    uint256 _reserve = reserve();
    uint256 wt = 0;
    for (uint256 i = 0; i < ids.length; i++) {
      wt = wt.add(tokens.computeWeightForAmount(tokens[i].tokenId, values[i]));
    }
    require(bdigg.transfer(operator, wt.mul(_reserve).div(tokens.computeTotalWeight(memeLtd))), "failed to transfer BDigg");
    return ERC1155Holder.onERC1155BatchReceived.selector;
  }
  function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes memory data) public virtual override returns (bytes4) {
    uint256[] memory ids = new uint256[](1);
    uint256[] memory values = new uint256[](1);
    ids[0] = id;
    values[0] = value;
    onERC1155BatchReceived(operator, from, ids, values, data);
    return ERC1155Holder.onERC1155Received.selector;
  }
}
