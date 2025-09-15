import { TronWeb } from "tronweb";
import fs from "fs";
import dotenv from "dotenv";

dotenv.config();
console.log(process.env.PRIVATE_KEY_TRON)
const tronWeb = new TronWeb({
  fullHost: process.env.TRON_NETWORK, // Testnet
  privateKey: process.env.PRIVATE_KEY_TRON,
});

// async function checkBalance() {
//   // get address from private key
//   const address = await tronWeb.address.fromPrivateKey(process.env.PRIVATE_KEY_TRON);


//   console.log(`address -------------->`, address)

//   const balanceInSun = await tronWeb.trx.getBalance("TMcvYed164kaQexMfXxerZtGY592gWRwgk"); // balance in Sun (1 TRX = 1e6 Sun)
//   const balanceInTRX = tronWeb.fromSun(balanceInSun);

//   console.log(`Address: ${address}`);
//   console.log(`Balance: ${balanceInTRX} TRX`);
// }

// checkBalance().catch(console.error);


let addr = "TFjs8m8MafwRurNc2jGy3zAz9mLBz65doM"
async function main() {
  const contractFile = JSON.parse(
    fs.readFileSync(
      "./artifacts/contracts/AzntToken.sol/AzntToken.json",
      "utf8"
    )
  );
  
  const abi = contractFile.abi;
  const bytecode = contractFile.bytecode;

  console.log("⏳ Deploying contract...");

  const contract = await tronWeb.contract().new({
    abi,
    bytecode,
    feeLimit: 100_000_000,
    parameters: [addr]
  });

  const base58Address = tronWeb.address.fromHex(contract.address);
  console.log("✅ Contract deployed at:", base58Address);
}

main().catch(console.error);


// TMcvYed164kaQexMfXxerZtGY592gWRwgk