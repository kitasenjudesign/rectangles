import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const deploy: DeployFunction = async function ({
    getNamedAccounts,
    deployments,
    getChainId,
    getUnnamedAccounts
}: HardhatRuntimeEnvironment) {
    const { deploy, execute } = deployments;
    const { deployer } = await getNamedAccounts();

    const MyERC721 = await deploy("MyERC721", {
        from: deployer,
        args: [process.env.PROXY_REGISTRY_ADDRESS, 'My special item', 'MSI', 'http://www.url.to/metadata/'],
    })

    console.log('MyERC721: ' + MyERC721.address);

    await execute('MyERC721', {from: deployer}, 'mint', deployer);
}

export default deploy;