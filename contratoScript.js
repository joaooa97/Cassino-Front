var rifa;
var userAccount;
var acc;

function startApp() {

    var cassinoAddress = "0x502c4a75328037c4C640de91B7EA22487178d432";
    var fichaAddress   = "0x6e9D5ecb69de32b17B6212caB20ca91272F0f592";

    cassino = new web3.eth.Contract(abi, cassinoAddress);
    ficha   = new web3.eth.Contract(abi, fichaAddress);

    var accountInterval = setInterval(function () {

        web3.eth.getAccounts().then(function (result) {
            acc = result[0];
        })

        if (acc !== userAccount) {
            userAccount = acc;
            refreshData();
        }
    }, 100);

}

// Métodos do Contrato das Fichas
function verFichas() {
    return ficha.methods.myBalance().call({from: userAccount});
}

// Métodos do Contrato do Cassino
function comprarFichas() {    
    var quant = document.getElementById("quantidade").value;
    var preco = 10000000000*quant;
    return cassino.methods.comprarFichas(quant).send({ from: userAccount, value: preco}).then(refreshData);;
}

/*function verPreco() {
    return rifa.methods.verPrecoDaRifa().call();
}

function verPremio() {
    return rifa.methods.verPremio().call();
}

function verTotalDeRifas() {
    return rifa.methods.verTotalDeRifas().call();
}

function refreshData() {
    verRifas().then((result) => {document.getElementById("total-rifas").innerHTML = result;});
    verTotalDeRifas().then((result) => {document.getElementById("total-geral").innerHTML = result;});
    verPremio().then((result) => {document.getElementById("premio").innerHTML = result/1000000000000000000 + " ETH";});
    verPreco().then((result) => {document.getElementById("preco").innerHTML = "Preço da Rifa: " + result/1000000000000000000 + " ETH";});
    verGanhador().then((result) => {document.getElementById("ganhador").innerHTML = result;});
    document.getElementById("endereco").innerHTML = userAccount;

    document.getElementById("drawBtn").style.display = "none";
    rifa.methods.isOwner().call({from: userAccount}).then((result) => {if (result) { document.getElementById("drawBtn").style.display = "block"; }});

}

function comprarRifa() {
    var quant = document.getElementById("quantidade").value;
    var preco = 100000000000000000*quant;
    rifa.methods.comprarRifa(quant).send({ from: userAccount, value: preco}).then(refreshData);
    return false;
}

function sortear() {
    rifa.methods.sortearRifa().send({ from: userAccount }).then(refreshData);
    return false;
}*/

// Padrão para detectar um web3 injetado.
window.addEventListener('load', function () {

    web3Provider = null;
    // Modern dapp browsers...
    if (window.ethereum) {
        web3Provider = window.ethereum;
        try {
            // Request account access
            window.ethereum.enable();
        } catch (error) {
            // User denied account access...
            console.error("User denied account access")
        }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
        web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
        console.log('No web3? You should consider trying MetaMask!')
        web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(web3Provider);
    startApp()

})