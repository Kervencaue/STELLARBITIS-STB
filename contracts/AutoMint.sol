//SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;
contract AutoMint is ERC20, Ownable {

    function mintTokens() public {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        uint256 tokensToMint = 32 ether;
        uint256 remaining = MAX_SUPPLY - totalSupply;
        if (tokensToMint > remaining) {
            tokensToMint = remaining;
        }
        balances[address(this)] = balances[address(this)].add(tokensToMint);
        totalSupply = totalSupply.add(tokensToMint);
        emit Transfer(address(0), address(this), tokensToMint);
    }

    function startMinting() public onlyOwner {
        require(!mintingStarted, "Minting already started");
        mintingStarted = true;
        lastMintedBlock = block.number;
        emit MintingStarted();
    }

    function stopMinting() public onlyOwner {
        require(mintingStarted, "Minting not yet started");
        mintingStarted = false;
        emit MintingStopped();
    }

    function mintOnBlock() public {
        require(mintingStarted, "Minting not yet started");
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        require(block.number > lastMintedBlock, "Block not yet mined");

        uint256 blockDiff = block.number - lastMintedBlock;
        uint256 tokensToMint = blockDiff.mul(32 ether);
        uint256 remaining = MAX_SUPPLY - totalSupply;
        if (tokensToMint > remaining) {
            tokensToMint = remaining;
        }

        balances[address(this)] = balances[address(this)].add(tokensToMint);
        totalSupply = totalSupply.add(tokensToMint);
        lastMintedBlock = block.number;
        emit Transfer(address(0), address(this), tokensToMint);
        emit Minted(tokensToMint);
    }

}