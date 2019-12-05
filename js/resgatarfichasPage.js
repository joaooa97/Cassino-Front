// Métodos do Contrato do Cassino  
function resgatarQtd()
{    
  var max = parseInt(document.getElementById("total-fichas").innerHTML);
  var quant = parseInt(document.getElementById("quantidade").value);

  if( quant > 0 )
  {
    if( quant > max )
    {
      alert("Você não possui esta quantidade de Fichas.");
    }
    else
    {
      alert("Tentando resgatar " + quant + " fichas, de " + max);
      cassino.methods.resgatarEthers(quant).send({ from: userAccount }).then(refreshData);
      document.getElementById("quantidade").value = "";
    }
  }
  else
  {
    alert("Digite uma quantidade positiva de Fichas.");
  }
}

function resgatarTudo()
{    
  var max = parseInt(document.getElementById("total-fichas").innerHTML);
  cassino.methods.resgatarEthers(max).send({ from: userAccount }).then(refreshData);
  document.getElementById("quantidade").value = "";
}

function refreshData() 
{
  verFichas().then((result) => {document.getElementById("total-fichas").innerHTML = result;});
  document.getElementById("endereco").innerHTML = userAccount;
}