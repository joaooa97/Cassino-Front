var userAccount;
var acc;

function startApp() 
{
  var cassinoAddress = "0x5CeFd05d0255759d972b58c7ae2b8BBaFfD652Eb";
  var fichaAddress   = "0x6e9D5ecb69de32b17B6212caB20ca91272F0f592";

  cassino = new web3.eth.Contract(abiCassino, cassinoAddress);
  ficha   = new web3.eth.Contract(abiFicha, fichaAddress);

  var accountInterval = setInterval(function ()
  {
    web3.eth.getAccounts().then(function (result) 
    {
        acc = result[0];
    })

    if (acc !== userAccount) 
    {
        userAccount = acc;
        refreshData();
    } 
  }, 100);
}

// Métodos do Contrato das Fichas
function verFichas() 
{
  return ficha.methods.myBalance().call({from: userAccount});
}

// Padrão para detectar um web3 injetado.
window.addEventListener('load', function () 
{

  web3Provider = null;
  // Modern dapp browsers...
  if (window.ethereum) 
  {
    web3Provider = window.ethereum;

    try 
    {
        // Request account access
        window.ethereum.enable();
    } 
    catch (error) 
    {
        // User denied account access...
        console.error("User denied account access")
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) 
  {
    web3Provider = window.web3.currentProvider;
  }
  // If no injected web3 instance is detected, fall back to Ganache
  else 
  {
    console.log('No web3? You should consider trying MetaMask!')
    web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
  }

  web3 = new Web3(web3Provider);
  startApp()
})