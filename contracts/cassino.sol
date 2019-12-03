// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <link>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.
pragma experimental ABIEncoderV2;

import "./jogo_cassino.sol";

contract RoletaInterface
{
	function verMultiplicadores() external view returns (uint8, uint8, uint8);
	function mudarMultiplicadores(uint8 individual, uint8 intervalo, uint8 cor) external;
	function saldoMaquina() external view returns (uint);
	function fazerApostaIntervalo(uint8 intervalo, uint16 valorAposta) external;
	function fazerApostaIndividual(uint8 numeroEscolhido, uint16 valorAposta) external;
	function fazerApostaCor(bool cor, uint16 valorAposta) external;
	function girarRoleta() external returns (uint8, uint8, bool, uint);
	function sacarPremio() external returns (uint);
} 

contract CacaNiqueisInterface
{
    function verMultiplicadores() external view returns ( uint8[9] );
    function mudarMultiplicadores( uint8 posicao, uint8 novoValor ) external;
	function saldoMaquina() external  view returns (uint);
	function fazerAposta(uint valorAposta) external;
	function sacarPremio() external returns (uint);
	function iniciarGiro() external returns (uint8[3], bool);
} 

contract LoteriaInterface
{
    function comprarBilhete(uint8[5] bilhete) external returns (bool);
    function retornarPremio() external view returns (uint);
    function meusBilhetes() external view returns (uint8[][]);
    function sortear() external returns (address[], uint8[5], uint);
} 

contract Cassino is JogoCassino
{	
    address RoletaAddress = 0xECFF47E65fB8E42b15c8F5Fa56DA0b997ebec365;
    RoletaInterface RoletaContract = RoletaInterface(RoletaAddress);
    
    address CacaNiqueisAddress = 0x288B47fd79DbBF22A749C1864Da2d7d8Af253C8C;
    CacaNiqueisInterface CacaNiqueisContract = CacaNiqueisInterface(CacaNiqueisAddress);
    
    address LoteriaAddress = 0x3B42b25C5acdd4E96664b1d169558824A5327497;
    LoteriaInterface LoteriaContract = LoteriaInterface(LoteriaAddress);
    
    // Tipos Aposta Roleta
	uint8 constant Individual = 0;
	uint8 constant Intervalo  = 1;
	uint8 constant Cor        = 2;
	
	// Valores para Compra e venda de Tokens
	uint valorCompra  = 10000000000;
	uint valorResgate = 8000000000;
	
	uint[5] ultimosPremiosRoleta;
	uint8 contadorPremiosRoleta = 0;
	
	uint[5] ultimosPremiosCacaNiqueis;
	uint8 contadorPremiosCacaNiqueis = 0;
	
	uint[5] ultimosPremiosLoteria;
	uint8 contadorPremiosLoteria = 0;
	
	constructor() public 
	{
	}
	
	function mudarValoresFCH(uint novoCompra, uint novoResgate ) external onlyOwner
	{
	    valorCompra  = novoCompra;
	    valorResgate = novoResgate;
	}
	
	function verSaldoEther() external view onlyOwner returns (uint)
	{
	    return address(this).balance;
	}
	
	function comprarFichas() payable external returns (uint)
	{
	    require(msg.value >= valorCompra, "Você não pagou o suficiente para comprar fichas.");
	    
	    uint qtdFichas = msg.value / valorCompra;
	    FCHContract.approve(msg.sender, qtdFichas);
	    
	    // Pode ser separado em duas funções: compra de token e saque de token.
	    FCHContract.transferFrom(address(this), msg.sender, qtdFichas);
	    
	    return qtdFichas;
	}
    
    function resgatarEthers(uint qtdFichas) external returns (uint)
    {
        require( FCHContract.transfer(address(this), qtdFichas) );
        
        uint resgate = qtdFichas * valorResgate;
        msg.sender.transfer( resgate );
        
        return resgate;
    }
    
    function alterarContratoJogos(uint8 id, address novoEndereco) external onlyOwner
	{
	    if( id == 0 )
	    {
    	    RoletaAddress = novoEndereco;
    	    RoletaContract = RoletaInterface(RoletaAddress);
	    }
	    else if( id == 1 )
	    {
    	    CacaNiqueisAddress = novoEndereco;
            CacaNiqueisContract = CacaNiqueisInterface(CacaNiqueisAddress);
	    }
	    else if( id == 2 )
	    {
    	    LoteriaAddress = novoEndereco;
    	    LoteriaContract = LoteriaInterface(LoteriaAddress);
	    }
	}
	
	// Chamadas Roleta
	
	function verMultiplicadoresRoleta() external view returns (uint8, uint8, uint8)
	{
	    return RoletaContract.verMultiplicadores();
	}
	
	function mudarMultiplicadoresRoleta(uint8 opcao, uint8 novoMultiplicador) external onlyOwner
	{
	    uint8 multIndividual;
	    uint8 multIntervalo;
	    uint8 multCor;
	    
	    (multIndividual, multIntervalo, multCor) = RoletaContract.verMultiplicadores();
	    
	    if( opcao == Individual )
	    {
	        RoletaContract.mudarMultiplicadores(novoMultiplicador, multIntervalo, multCor);
	    }
	    else if( opcao == Intervalo )
	    {
	        RoletaContract.mudarMultiplicadores(multIndividual, novoMultiplicador, multCor);
	    }
	    else if( opcao == Cor)
	    {
	        RoletaContract.mudarMultiplicadores(multIndividual, multIntervalo, novoMultiplicador);
	    }
	}
	
	function apostarRoleta(uint8 tipoAposta, uint8 aposta, uint16 valor) external returns (uint8, uint8, bool, uint) 
	{
	    if( tipoAposta == Individual)
	    {
	        RoletaContract.fazerApostaIndividual(aposta, valor);
	    }
	    else if( tipoAposta == Intervalo)
	    {
	        RoletaContract.fazerApostaIntervalo(aposta, valor);
	    }
	    else if( tipoAposta == Cor )
	    {
	        bool corAposta = false;
	        
	        if( aposta > 0)
	            corAposta = true;
	            
	        RoletaContract.fazerApostaCor(corAposta, valor);
	    }
	    
	    uint8 numero;
	    uint8 cor;
	    bool ganhou;
	    uint premio;
	    
	    (numero, cor, ganhou, premio) = RoletaContract.girarRoleta();
	    
	    if( ganhou )
	    {
	        sacarPremioRoleta();
	    }
	    
	    return (numero, cor, ganhou, premio);
	}
	
	function checarSaldoDaRoleta() external view onlyOwner returns (uint) 
	{
	    return RoletaContract.saldoMaquina();
	}
	
	function sacarPremioRoleta() internal returns (uint)
	{
	    // Armazenar estatisticas de ganhos aqui.
	    uint premio = RoletaContract.sacarPremio();
	    
	    
	    if( premio > 0 )
	    {
	        if( contadorPremiosRoleta == 5)
	        {
	            contadorPremiosRoleta = 0;
	        }
	        
	        ultimosPremiosRoleta[contadorPremiosRoleta] = premio;
	        contadorPremiosRoleta++;
	    }
	    
	    return premio;
	}
	
	// ---------------------------------------------- Fim Roleta -------------------------------------------- //
	
	// Chamadas Caça Niqueis
	function verMultiplicadoresCacaNiqueis() external view onlyOwner returns (uint8[9])
	{
	    return CacaNiqueisContract.verMultiplicadores();
	}
	
	function mudarMultiplicadoresCacaNiqueis(uint8 posicao, uint8 novoMultiplicador) external onlyOwner
	{
	    CacaNiqueisContract.mudarMultiplicadores(posicao, novoMultiplicador);
	}
	
	function checarSaldoDoCacaNiqueis() external view onlyOwner returns (uint)
	{
	    return CacaNiqueisContract.saldoMaquina();
	}
	
	function apostarCacaNiqueis (uint valorAposta) external returns (uint8[3], bool, uint)
	{
	    CacaNiqueisContract.fazerAposta(valorAposta);
	    
	    uint8[3] memory resultado;
	    bool ganhou;
	    uint premio;
	    
	    (resultado, ganhou) = CacaNiqueisContract.iniciarGiro();
	    
	    if( ganhou )
	    {
	        premio = sacarPremioCacaNiqueis();
	    }
	    
	    return (resultado, ganhou, premio); 
	}
	
	function sacarPremioCacaNiqueis() internal returns (uint)
	{
	    // Armazenar estatisticas de ganhos aqui.
	    uint premio = CacaNiqueisContract.sacarPremio();
	    
	    
	    if( premio > 0 )
	    {
	        if( contadorPremiosCacaNiqueis == 5)
	        {
	            contadorPremiosCacaNiqueis = 0;
	        }
	        
	        ultimosPremiosCacaNiqueis[contadorPremiosCacaNiqueis] = premio;
	        contadorPremiosCacaNiqueis++;
	    }
	    
	    return premio;
	}
	
	// ---------------------------------------------- Fim Caca Niqueis -------------------------------------------- //
	
	// Chamadas Loteria
	function premioAtualLoteria() external view returns (uint)
	{
	    uint premio = LoteriaContract.retornarPremio();
	    return premio;
	}
	
	function comprarBilheteLoteria(uint8[5] bilhete) external returns (bool)
	{
	    // WTF, só funcionou assim.
	    uint8[5] memory bilheteF = bilhete;
	    
	    return LoteriaContract.comprarBilhete(bilheteF);
	}
	
	function verMeusBilhetesLoteria() external view returns (uint8[][])
	{
	    return LoteriaContract.meusBilhetes();
	}
	
	function sortearLoteria() external onlyOwner returns (address[], uint8[5], uint)
	{
	    return LoteriaContract.sortear();
	}
}