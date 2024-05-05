import {
  NFTCreated as NFTCreatedEvent,
  NFTRegesitered as NFTRegesiteredEvent,
  OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/NFTFactory/NFTFactory"
import {
  NFTCreated,
  NFTRegesitered,
  OwnershipTransferred
} from "../generated/schema"

import {NFT} from "../generated/schema"

export function handleNFTCreated(event: NFTCreatedEvent): void {
  let entity = new NFTCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  // 创建S2NFT的时候，合约地址肯定是唯一的，可以作为id使用
  let ca = entity.nftCA;
  let nft = new NFT(ca.toHex());
  nft.ca = ca;
  nft.save();
}

export function handleNFTRegesitered(event: NFTRegesiteredEvent): void {
  let entity = new NFTRegesitered(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
