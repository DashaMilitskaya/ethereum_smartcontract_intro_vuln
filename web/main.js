let accounts = [];
let currentAccount;
const web3 = new Web3(ethereum);
var defaultChainId = '0x13882';
const defaultChainName = "Polygon Amoy";

const factoryAddress = "0x5A1b4c66b7cdC2655A9E62807043A4905C2cc3C4";

const defaultVulnDeployAmount = 1000000;

async function getCurrentChainId() {

  return await ethereum
    .request({
      method: 'eth_chainId'
    });
}

function setNetStatus (str) {
  document.getElementById("netStatus").innerText = str;
  document.getElementById("netStatus").style.color = "SpringGreen";
}

function connectCallback (res) {
  accounts = res;
  currentAccount = accounts[0];
  console.log('currentAccount', currentAccount);
  
  document.getElementById("connectStatus").innerText = currentAccount;
  document.getElementById("connectStatus").style.color = "SpringGreen";
  
  switchEthereumChain(defaultChainId);

}

function connect() {
  ethereum
    .request({
      method: 'eth_requestAccounts',
      params: [],
    })
    .then(connectCallback)
    .catch((e) => console.log('request accounts ERR', e));
}

async function switchEthereumChainCallback (res) {
  console.log('switch', res)
  setNetStatus (await getCurrentChainId());
}

async function switchEthereumChain (chainId) {

  let currentChainId = await getCurrentChainId();
  //console.log ("currentChainId ", currentChainId);
  if (currentChainId == chainId) {
    setNetStatus (currentChainId);
    console.log('chainId already ', chainId)
    return;
  }

  window.ethereum.request({
    method: 'wallet_switchEthereumChain',
    params: [{ chainId: chainId, }]}).
  then (switchEthereumChainCallback).
  catch (e => {
    console.log ("switch error: ", e);
    addEthereumChain(chainId, defaultChainName);
  });

}

function addEthereumChain (chainId, chainName) {
  
  ethereum
    .request({
      method: 'wallet_addEthereumChain',
      params: [
        
        {
          chainId: chainId,
          chainName: chainName,
          blockExplorerUrls: ['https://amoy.polygonscan.com'],
          nativeCurrency: { symbol: 'MATIC', decimals: 18 },
          rpcUrls: ['https://rpc-amoy.polygon.technology'],
        },
      ],
    })
    .then(switchEthereumChainCallback)
    .catch((e) => console.log('ADD ERR', e));
}
