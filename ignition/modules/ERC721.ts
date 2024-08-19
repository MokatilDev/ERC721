import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ERC721Module = buildModule("ERC721Module", (m) => {
  const name = m.getParameter("name", "Mokatil NFT");
  const symbol = m.getParameter("symbol", "MKT");
  const ERC721 = m.contract("ERC721", [name, symbol]);

  return { ERC721 };
});

export default ERC721Module;
