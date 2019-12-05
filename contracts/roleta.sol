// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <https://ropsten.etherscan.io/address/0xECFF47E65fB8E42b15c8F5Fa56DA0b997ebec365>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.
pragma experimental ABIEncoderV2;

import "./jogo_cassino.sol";

contract Roleta is JogoCassino
{	
	uint8 private constant Individual = 0;
	uint8 private constant Intervalo  = 1;
	uint8 private constant Cor        = 2;
	
	uint8 private multiplicadorApostaIndividual = 35;
	uint8 private multiplicadorApostaIntervalo  = 1;
	uint8 private multiplicadorApostaCor        = 1;
	
    mapping(address	=> Aposta[]) private apostas;
    mapping(uint8	=> uint8) private numerosRoleta;
	
	mapping (address => uint8) private status;          // 0 - Parado , 1 - Aguardando Giro , 2 - Aguardando Saque
	mapping (address => uint) private premiosGanhos;
    
	struct Aposta
	{
	    uint8 tipo;
	    uint8 numero;
	    uint16 valor;
	}
	
	function verMultiplicadores() external view onlyOwner returns (uint8, uint8, uint8)
	{
	    return (multiplicadorApostaIndividual, multiplicadorApostaIntervalo, multiplicadorApostaCor);
	}
	
	function mudarMultiplicadores(uint8 individual, uint8 intervalo, uint8 cor) external onlyOwner
	{
    	multiplicadorApostaIndividual = individual;
    	multiplicadorApostaIntervalo  = intervalo;
    	multiplicadorApostaCor        = cor;
	}
	
	constructor() public 
	{
	    uint8[37] memory numeros  = [uint8(0),32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26];
	    
	    for(uint8 i = 0; i < 37; i++)
	    {
	        numerosRoleta[ numeros[i] ] = (i%2);
	    }
    }	
	
	// Checar saldo da máquina
	function saldoMaquina() external view onlyOwner returns (uint)
	{
	    return FCHContract.myBalance();
	}
	
	function checarSaldoTransferir(uint valor) internal
	{
	    // Só pode jogar após recolher os premios ganhos.
        require( status[tx.origin] == 0 , "Você deve terminar sua jogada e recolher os premios, caso haja.");
        
        // Condicionar aposta em um intervalo de valores.
        require( valor >= 5, "Valor mínimo de aposta 5." );
        
        // Inserir o valor na carteira de tokens da máquina.
        require( FCHContract.transfer( address(this), valor ) , "Você não tem saldo suficiente para jogar." );
	}
	
	// Fazer aposta em um intervalo de números.
	function fazerApostaIntervalo(uint8 intervalo, uint16 valorAposta) external
	{
	    // Checar saldo do apostador e transferir para a roleta.
	    checarSaldoTransferir(valorAposta);
	    
	    uint8 inter = intervalo % 3;
	    
	    apostas[tx.origin].push( Aposta( Intervalo, inter, valorAposta ) );
	    status[tx.origin] = 1;
	}
	
	// Fazer aposta em um número individual.
	function fazerApostaIndividual(uint8 numeroEscolhido, uint16 valorAposta) external
	{
	    // Checar saldo do apostador e transferir para a roleta.
	    checarSaldoTransferir(valorAposta);
	    
	    apostas[tx.origin].push( Aposta( Individual, numeroEscolhido, valorAposta) );
	    status[tx.origin] = 1;
	}
	
	// Fazer aposta pela cor.
	function fazerApostaCor(bool cor, uint16 valorAposta) external
	{
	    // Checar saldo do apostador e transferir para a roleta.
	    checarSaldoTransferir(valorAposta);
	    
	    uint8 corAposta = 0;
	    
	    // Checar saldo do apostador e transferir para a roleta.
	    if( cor )
	        corAposta = 1;
	    
	    apostas[tx.origin].push( Aposta( Cor, corAposta, valorAposta ) );
	    status[tx.origin] = 1;
	}
	
	// Girar Roleta
	function girarRoleta() external returns (uint8, uint8, bool, uint) 
	{
	    // Gerando números aleatórios entre 1 e 100:
        uint8 random = uint8(keccak256(abi.encodePacked(now, msg.sender))) % 37;
        uint8 resultadoValor = random;
        uint8 resultadoCor   = numerosRoleta[random];
        
        require(status[tx.origin] == 1, "Você precisa fazer uma aposta para girar a roleta.");
        
        status[tx.origin] = 0;
        
        bool ganhou = false;
        
        if( resultadoValor != 0 )
        {
            // TODO: Adicionar Eventos
            for(uint8 i = 0; i < apostas[tx.origin].length; i++)
            {
                uint8 tipoAposta  = apostas[tx.origin][i].tipo;
                uint8 numero      = apostas[tx.origin][i].numero;
                uint16 valor       = apostas[tx.origin][i].valor;
                
                if( tipoAposta == Individual )
                {
                    if( resultadoValor == numero )
                    {
                        premiosGanhos[tx.origin] += ( valor + ( multiplicadorApostaIndividual * valor) );
                        ganhou = true;
                    }
                }
                else if( tipoAposta == Intervalo )
                {
                    if( (resultadoValor >= 1) && (resultadoValor <= 12) && (numero == 0) )
                    {
                        premiosGanhos[tx.origin] += ( valor + ( multiplicadorApostaIntervalo * valor) );
                        ganhou = true;
                    }
                    else if( (resultadoValor >= 13 && resultadoValor <= 24) && (numero == 1) )
                    {
                        premiosGanhos[tx.origin] += ( valor + ( multiplicadorApostaIntervalo * valor) );
                        ganhou = true;
                    }
                    else if( (resultadoValor >= 25 && resultadoValor <= 36) && (numero == 2) )
                    {
                        premiosGanhos[tx.origin] += ( valor + ( multiplicadorApostaIntervalo * valor) );
                        ganhou = true;
                    }
                }
                else // tipoAposta == Cor
                {
                    if( resultadoCor == numero )
                    {
                        premiosGanhos[tx.origin] += ( valor + ( multiplicadorApostaCor * valor) );
                        ganhou = true;
                    }
                }
            }
        }
        
        if( ganhou )
        {
	        FCHContract.approve( tx.origin, premiosGanhos[tx.origin] );
            status[tx.origin] = 2;
        }
        
        delete apostas[tx.origin];
	    
        return (resultadoValor, resultadoCor, ganhou, premiosGanhos[tx.origin]);
	}
	
	// Sacar Premio
	function sacarPremio() external returns (uint)
	{
        require( status[tx.origin] == 2, "Para sacar você deve ter ganho." );
	    
	    require( FCHContract.transferFrom( address(this), tx.origin, premiosGanhos[tx.origin] ), "Maquina sem tokens no momento." );
	    
	    uint premio = premiosGanhos[tx.origin];
	    premiosGanhos[tx.origin] = 0;
        status[tx.origin] = 0;
	    
        return premio;
	}
}