import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("ERC721", function () {

    async function deployERC721Fixture() {
        const name = "Mokatil NFT";
        const symbol = "MKT";

        const ERC721 = await hre.ethers.deployContract("ERC721", [name, symbol]);
        const [owner, addr1, addr2] = await hre.ethers.getSigners();

        return { ERC721, name, symbol, owner, addr1, addr2 }
    }

    it("Should return the correct name and symbol", async function () {
        const { ERC721, name, symbol } = await loadFixture(deployERC721Fixture);

        expect(await ERC721.name()).to.equal(name);
        expect(await ERC721.symbol()).to.equal(symbol);
    })

    it("Should return the contract owner", async function () {
        const { ERC721, owner } = await loadFixture(deployERC721Fixture);

        expect(await ERC721.contractOwner()).to.equal(owner.address);
    })

    it("Shoudl mint a new ERC721 token", async function () {
        const { ERC721, addr1 } = await loadFixture(deployERC721Fixture);

        await ERC721.mintTo(addr1.address, "Hello Wolrd");
        expect(await ERC721.totalSupply()).to.equal(1);
        expect(await ERC721.ownerOf(0)).to.equal(addr1.address);
        expect(await ERC721.tokenURI(0)).to.equal("Hello Wolrd");
    })

    it("Should fail to mint if not owner", async function () {
        const { ERC721, addr1 } = await loadFixture(deployERC721Fixture);

        await expect(ERC721.connect(addr1).mintTo(addr1.address, "Hello World")).to.be.revertedWith("You are not the owner");
    })

    it("Should transfer a token", async function () {
        const { ERC721, addr1, addr2 } = await loadFixture(deployERC721Fixture);
        await ERC721.mintTo(addr1.address, "Hello Wolrd")
        await ERC721.transferFrom(addr1.address, addr2.address, 0);

        expect(await ERC721.ownerOf(0)).to.equal(addr2.address);
        expect(await ERC721.balanceOf(addr1.address)).to.equal(0);
        expect(await ERC721.balanceOf(addr2.address)).to.equal(1);
    })

    it("Should approve and transfer a token", async function () {
        const { ERC721, addr1, addr2 } = await loadFixture(deployERC721Fixture);
        await ERC721.mintTo(addr1.address, "Hello World");
        await ERC721.connect(addr1).approve(addr2.address, 0);

        expect(await ERC721.getApproved(0)).to.equal(addr2.address);

        await ERC721.connect(addr2).transferFrom(addr1.address, addr2.address, 0);
        expect(await ERC721.ownerOf(0)).to.equal(addr2.address);
    })


    it("Should set and check operator approval", async function () {
        const { ERC721, addr1, addr2 } = await loadFixture(deployERC721Fixture);
        await ERC721.mintTo(addr1.address, "Hello World");
        await ERC721.connect(addr1).setApprovalForAll(addr2.address, true);

        expect(await ERC721.isApprovedForAll(addr1.address,addr2.address)).to.equal(true);
    })

});
