function comprarBilhete()
{ 
  var precoBilhete = 50;
  var max = parseInt(document.getElementById("total-fichas").innerHTML);
 
  if( precoBilhete > max )
  {
    alert("Você não possui Fichas suficientes para comprar um bilhete.");
  }
  else
  {

    bilheteValido = true;

    var numerosBilhete = [];

    numerosBilhete[0] = parseInt(document.getElementById("numeros_bilhete1").value);
    numerosBilhete[1] = parseInt(document.getElementById("numeros_bilhete2").value);
    numerosBilhete[2] = parseInt(document.getElementById("numeros_bilhete3").value);
    numerosBilhete[3] = parseInt(document.getElementById("numeros_bilhete4").value);
    numerosBilhete[4] = parseInt(document.getElementById("numeros_bilhete5").value);

    for(var i = 0; i < 5; i++)
    {
      if( numerosBilhete[i] < 0 || numerosBilhete[i] > 5 )
      {
        bilheteValido = false;
        break;
      }
    }

    if( bilheteValido )
    {
      console.log("Bilhete para Comprar: " + numerosBilhete);

      cassino.methods.comprarBilheteLoteria(numerosBilhete).send({from: userAccount}).then(function(receipt)
      {
        //console.log( receipt );
        var numeros    = receipt["events"]["novoBilheteLoteria"]["returnValues"]["numero"];
        var jaComprou  = receipt["events"]["novoBilheteLoteria"]["returnValues"]["jaComprou"];

        // console.log(numeros);
        // console.log(jaComprou);
        refreshData();
      });
    }  
    else
    {
      alert("Bilhete Inválido: Algum número é maior que 5 ou menor que 0.");
    }    
  }

  document.getElementById("numeros_bilhete1").value = "";
  document.getElementById("numeros_bilhete2").value = "";
  document.getElementById("numeros_bilhete3").value = "";
  document.getElementById("numeros_bilhete4").value = "";
  document.getElementById("numeros_bilhete5").value = "";

}

function sortear()
{
  cassino.methods.sortearLoteria().send({from: userAccount}).then(function(receipt)
  {
    console.log( receipt );
    var ganhadores    = receipt["events"]["novoVencedoresLoteria"]["returnValues"]["0"];
    var bilhete       = receipt["events"]["novoVencedoresLoteria"]["returnValues"]["1"];
    var premio        = receipt["events"]["novoVencedoresLoteria"]["returnValues"]["2"];

    // console.log(ganhadores);
    // console.log(bilhete);
    // console.log(premio);

    document.getElementById("bilheteSorteado").innerHTML = "[" + bilhete + "]";

    stringGanhadores = "";

    for( var i = 0; i < ganhadores.length; i ++ )
    {
      stringGanhadores += "[" + ganhadores[i] + "]";

      if( i != (ganhadores.length-1) )
        stringGanhadores += ", ";
    }

    document.getElementById("ganhadores").innerHTML = stringGanhadores;
    
    refreshData();

  });
}

function refreshData() 
{
  verFichas().then((result) => {document.getElementById("total-fichas").innerHTML = result;});
  
  document.getElementById("drawBtn").style.display = "none";
  cassino.methods.isOwner().call({from: userAccount}).then((result) => {if (result) { document.getElementById("drawBtn").style.display = "block"; }});
  
  cassino.methods.verMeusBilhetesLoteria().call({from: userAccount}).then((result) => 
  {
    stringBilhetes = "";

    for( var i = 0; i < result.length; i ++ )
    {
      stringBilhetes += "[" + result[i] + "]";

      if( i != (result.length-1) )
        stringBilhetes += ", ";
    }

    // console.log("Original: " + result);
    // console.log("Original Size: " + result.length);
    // console.log("Bilhetes: " + stringBilhetes);

    document.getElementById("meus-bilhetes").innerHTML = stringBilhetes;
  });
  
  verPremio().then((result) => {document.getElementById("premio").innerHTML = result + " FCH";});
  document.getElementById("endereco").innerHTML = userAccount;
}

function verPremio()
{
  return cassino.methods.premioAtualLoteria().call({from: userAccount});
}