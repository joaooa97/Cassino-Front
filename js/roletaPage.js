var tipoAposta;
var aposta;
var valor;

function tipoSelecionado()
{
  var element = document.getElementById("IGSelecAposta");
  var tipo = parseInt(element.options[element.selectedIndex].value);

  if( tipo >= 0 )
  {
    tipoAposta = tipo;

    switch( tipo )
    {
      case 0:
        document.getElementById("numeroAposta").disabled = false;
        document.getElementById("quantidade").disabled = false;
        document.getElementById("btnApostar").disabled = false;

        document.getElementById("IGselectIntervalo").disabled = true;
        document.getElementById("IGselectCor").disabled = true;
      break;

      case 1:
        document.getElementById("numeroAposta").disabled = true;
        document.getElementById("quantidade").disabled = true;
        document.getElementById("btnApostar").disabled = true;

        document.getElementById("IGselectIntervalo").disabled = false;
        document.getElementById("IGselectCor").disabled = true;
      break;

      case 2:
        document.getElementById("numeroAposta").disabled = true;
        document.getElementById("quantidade").disabled = true;
        document.getElementById("btnApostar").disabled = true;

        document.getElementById("IGselectIntervalo").disabled = true;
        document.getElementById("IGselectCor").disabled = false;
      break;
    }
  }
  else
  {
    document.getElementById("numeroAposta").disabled = true;
    document.getElementById("IGselectIntervalo").disabled = true;
    document.getElementById("IGselectCor").disabled = true;
  }
}

function intervaloSelecionado()
{
  var element = document.getElementById("IGselectIntervalo");
  var tipo = parseInt(element.options[element.selectedIndex].value);

  if( tipo >= 0 )
  {
    aposta = tipo;

    document.getElementById("quantidade").disabled = false;
    document.getElementById("btnApostar").disabled = false;
  }
  else
  {
    document.getElementById("quantidade").disabled = true;
    document.getElementById("btnApostar").disabled = true;
  }
}

function corSelecionada()
{
  var element = document.getElementById("IGselectCor");
  var tipo = parseInt(element.options[element.selectedIndex].value);

  if( tipo >= 0 )
  {
    aposta = tipo;

    document.getElementById("quantidade").disabled = false;
    document.getElementById("btnApostar").disabled = false;
  }
  else
  {
    document.getElementById("quantidade").disabled = true;
    document.getElementById("btnApostar").disabled = true;
  }
}

function fazerApostaRoleta()
{ 
  var valid = true;

  valor = document.getElementById("quantidade").value;

  if( tipoAposta == 0 )
  {
    aposta = document.getElementById("numeroAposta").value;

    if( aposta <= 0 || aposta > 36)
    {
      alert("Aposta fora dos limites !");
      valid = false;
    }
  }

  if( valid )
  {
    // alert("Tipo Aposta: " + tipoAposta + " Aposta: " + aposta + " Valor: " + valor);

    var max = parseInt(document.getElementById("total-fichas").innerHTML);

    if( valor > 0 )
    {
      if( valor > max )
      {
        alert("Você não possui esta quantidade de Fichas.");
      }
      else
      {
        // Teste para pegar varios retornos.
        cassino.methods.apostarRoleta(tipoAposta,aposta,valor).send({from: userAccount}).then(function(receipt)
        {
          //console.log( receipt );
          var numero  = receipt["events"]["novoGiroRoleta"]["returnValues"]["numero"];
          var cor   = receipt["events"]["novoGiroRoleta"]["returnValues"]["cor"];
          var ganhou  = receipt["events"]["novoGiroRoleta"]["returnValues"]["ganhou"];
          var premio  = receipt["events"]["novoGiroRoleta"]["returnValues"]["premio"];

          // console.log( "Numero: " + numero);
          // console.log( "Cor: " + cor);
          // console.log( "Ganhou: " + ganhou);
          // console.log( "Premio: " + premio);
          girarRoleta(numero);

          // Aguarda a roleta parar para notificar e atualizar fichas.
          setTimeout(function() 
          {
            if( ganhou )
                {
                  alert("Você Ganhou " + premio + " Fichas!");
                }
                else
                {
                  alert("Você Perdeu!");
                }

                refreshData();
          }, 10000);            
        });

        document.getElementById("quantidade").value = "";
      }
    }
    else
    {
      alert("Digite uma quantidade positiva de Fichas.");
    }

    document.getElementById("quantidade").value = "";
  }
}

function refreshData() 
{
  verFichas().then((result) => {document.getElementById("total-fichas").innerHTML = result;});
  document.getElementById("endereco").innerHTML = userAccount;
}