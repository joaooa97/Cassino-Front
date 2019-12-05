// Métodos do Contrato do Cassino
function comprarFichas()
{    
  var quant = document.getElementById("quantidade").value;
  var preco = 10000000000*quant;
  document.getElementById("quantidade").value = "";
  return cassino.methods.comprarFichas().send({ from: userAccount, value: preco}).then(refreshData);
}

function refreshData() 
{
  verFichas().then((result) => {document.getElementById("total-fichas").innerHTML = result;});
  document.getElementById("endereco").innerHTML = userAccount;
}