import {HardhatUserConfig} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
// @ts-ignore
import * as dotenv from 'dotenv';

dotenv.config();

const QUICKNODE_HTTP_URL = process.env.QUICKNODE_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
const POLYGONSCAN_KEY = process.env.POLYGONSCAN_KEY;

const config: HardhatUserConfig = {
    solidity: "0.8.17",
    networks: {
        mumbai: {
            url: QUICKNODE_HTTP_URL,
            accounts: [PRIVATE_KEY]
        }
    },
    // @ts-ignore
    etherscan: {
        apiKey: {
            polygonMumbai: POLYGONSCAN_KEY
        }
    }
};

export default config;
