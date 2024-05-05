import { Address, BigInt } from '@graphprotocol/graph-ts';
import { S2NFT,Transfer } from '../generated/templates/S2NFT/S2NFT'
import { TokenInfo,NFT } from '../generated/schema'

// 无论是mint，transfer还是safeTransfer最终都会触发Transfer事件
export function handleNFTTransfer(event: Transfer): void {
  let nft = NFT.load(event.address.toHex());
  // 如果该NFT不是S2NFTFactory创建出来的，那么就不存在
  if (nft) {
    let tokenId = event.params.tokenId
    let tokenInfoId = event.address.toHex().concat("#").concat(tokenId.toHex())
    // 查询TokenInfo是否已经存在
    let entity = TokenInfo.load(tokenInfoId);
    // 不存在则创建，存在的话只是更新
    if (!entity) {
      entity = new TokenInfo(tokenInfoId);
      entity.ca = event.address;
      entity.name = fetchName(event.address);
      entity.tokenId = event.params.tokenId;
      entity.tokenURL = fetchTokenUri(event.address, entity.tokenId);
    }

    entity.owner = event.params.to;
    entity.blockNumber = event.block.number;
    entity.blockTimestamp = event.block.timestamp;
    entity.transactionHash = event.transaction.hash;

    entity.save();
  }
}

// 获取S2NFT合约的名字
export function fetchName(address: Address): string {
  const nft = S2NFT.bind(address);
  const result = nft.try_name();
  if (!result.reverted) {
    return result.value;
  }

  return "";
}


// 获取S2NFT合约的TokenUri
export function fetchTokenUri(address: Address, tokenId: BigInt): string {
  const nft = S2NFT.bind(address);
  const result = nft.try_tokenURI(tokenId);
  if (!result.reverted) {
    return result.value;
  }

  return "";
}


