// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { StringLib } from "./StringLib.sol";
import { IMemeLtd } from "./IMemeLtd.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

library BadgerScarcityPoolLib {
  using StringLib for *;
  using SafeMath for *;
  struct PoolToken {
    uint256 tokenId;
    uint256 root;
  }
  function getPoolTokenRecord(PoolToken[] storage poolTokens, uint256 tokenId) internal view returns (PoolToken storage) {
    for (uint256 i = 0; i < poolTokens.length; i++) {
      if (poolTokens[i].tokenId == tokenId) return poolTokens[i];
    }
    revert(abi.encodePacked("tokenId not found: ", bytes32(tokenId).toString()).toString());
  }
  function computeTotalWeightForToken(PoolToken storage poolToken, IMemeLtd memeLtd) internal view returns (uint256 result) {}/*
    result = poolToken.root
      .mul(memeLtd.totalSupply(poolToken.tokenId).sub(memeLtd.balanceOf(address(this), poolToken.tokenId)));
  }*/
  function computeWeightForAmount(PoolToken[] storage poolTokens, uint256 tokenId, uint256 amount) internal view returns (uint256 result) {
    result = amount.mul(getPoolTokenRecord(poolTokens, tokenId).root);
  }
  function computeTotalWeight(PoolToken[] storage poolTokens, IMemeLtd memeLtd) internal view returns (uint256 total) {
    for (uint256 i = 0; i < poolTokens.length; i++) {
      total = total.add(computeTotalWeightForToken(poolTokens[i], memeLtd)); 
    }
  }
}
