import { Address, BigInt, log } from '@graphprotocol/graph-ts';
import { S2NFT,Transfer } from '../generated/templates/S2NFT/S2NFT'
import { TokenInfo,NFT } from '../generated/schema'

export function handleNFTTransfer(event: Transfer): void {
  const s2nft = S2NFT.bind(event.address)
  const tokenId = event.params.tokenId
  const tokenURI = s2nft.tokenURI(tokenId)
  const owner = event.params.to
  const tokenInfo = new TokenInfo(tokenId.toString() + "-" + event.address.toHex())
  tokenInfo.ca = event.address
  tokenInfo.tokenId = tokenId
  tokenInfo.tokenURL = tokenURI
  tokenInfo.name = s2nft.name()
  tokenInfo.owner = owner
  tokenInfo.blockNumber = event.block.number
  tokenInfo.blockTimestamp = event.block.timestamp
  tokenInfo.transactionHash = event.transaction.hash

  tokenInfo.save()
}


