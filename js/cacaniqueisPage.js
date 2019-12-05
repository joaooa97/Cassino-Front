casino1 = document.querySelector('#casino1');
casino2 = document.querySelector('#casino2');
casino3 = document.querySelector('#casino3');

mCasino1 = new SlotMachine(casino1, {
  active: 3,
  delay: 150
});

mCasino2 = new SlotMachine(casino2, {
  active: 2,
  delay: 100
});

mCasino3 = new SlotMachine(casino3, {
  active: 1,
  delay: 200
});

function fazerApostaCacaNiqueis()
{ 
  var valor = parseInt(document.getElementById("quantidade").value);
  var max = parseInt(document.getElementById("total-fichas").innerHTML);

  if( valor > 0 )
  {
    if( valor > max )
    {
      alert("Você não possui esta quantidade de Fichas.");
    }
    else
    {
      cassino.methods.apostarCacaNiqueis(valor).send({from: userAccount}).then(function(receipt)
      {
        //console.log( receipt );
        var numeros = receipt["events"]["novoGiroCacaNiqueis"]["returnValues"]["numeros"];
        var ganhou  = receipt["events"]["novoGiroCacaNiqueis"]["returnValues"]["ganhou"];
        var premio  = receipt["events"]["novoGiroCacaNiqueis"]["returnValues"]["premio"];


        mCasino1.randomize = function(){ return numeros[0]; };
        mCasino2.randomize = function(){ return numeros[1]; };
        mCasino3.randomize = function(){ return numeros[2]; };

        mCasino1.shuffle(20);
        mCasino2.shuffle(15);
        mCasino3.shuffle(10);

        // console.log(numeros);
        // console.log(ganhou);
        // console.log(premio);

        //Aguarda a roleta parar para notificar e atualizar fichas.
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
        }, 5000);

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

function refreshData() 
{
  verFichas().then((result) => {document.getElementById("total-fichas").innerHTML = result;});
  document.getElementById("endereco").innerHTML = userAccount;
}