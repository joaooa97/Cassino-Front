// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <https://ropsten.etherscan.io/address/0x288B47fd79DbBF22A749C1864Da2d7d8Af253C8C>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.

import "./jogo_cassino.sol";

contract Cacaniqueis is JogoCassino
{	
	uint8[9] private premios = [1, 2, 5, 10, 15, 20, 30, 40, 50];
	
	mapping (address => uint8) private status;          // 0 - Parado , 1 - Aguardando Giro , 2 - Aguardando Saque
	mapping (address => uint) private premiosGanhos;
	
	function verMultiplicadores() external view onlyOwner returns ( uint8[9] )
	{
	    return premios;
	}
	
	function mudarMultiplicadores( uint8 posicao, uint8 novoValor ) external onlyOwner
	{
	    premios[posicao] = novoValor;
	}
	
	// Checar saldo da máquina
	function saldoMaquina() external view onlyOwner returns (uint)
	{
	    return FCHContract.myBalance();
	}
	
	// Fazer aposta
	function fazerAposta(uint valorAposta) external
	{
	    // Só pode jogar após recolher os premios ganhos.
        require( status[tx.origin] == 0 , "Você deve terminar sua jogada e recolher os premios, caso haja.");
        
        // Condicionar aposta em um intervalo de valores.
        require( valorAposta >= 10, "Valor mínimo de aposta 10." );
        
        // Inserir o valor na carteira de tokens da máquina.
        require( FCHContract.transfer( address(this), valorAposta ) , "Você não tem saldo suficiente para jogar." );
	    
	    premiosGanhos[tx.origin] = valorAposta;
	    
        status[tx.origin] = 1;
	}
	
	// Sacar tokens ganhos
	function sacarPremio() external returns (uint)
	{
	    require( status[tx.origin] == 2, "Para sacar você deve ter ganho." );
	    
	    require( FCHContract.transferFrom( address(this), tx.origin, premiosGanhos[tx.origin] ) );
	    
	    uint premio = premiosGanhos[tx.origin];
	    premiosGanhos[tx.origin] = 0;
	    
        status[tx.origin] = 0;
        
        return premio;
	}
	
	// Girar
	function iniciarGiro() external returns (uint8[3], bool)
	{
	    require( status[tx.origin] == 1, "Você deve inserir tokens para girar." );
	    
	    uint8[3] memory resultado;
	    
	    for( uint i = 0; i < 3; i++)
	    {
    	    // Gerando números aleatórios entre 0 e 8:
            uint8 random = uint8(keccak256(abi.encodePacked(now, msg.sender, i))) % 9;
            resultado[i] = random;
	    }
	    
	    // Checar se ganhou, e entregar o premio.
	    bool ganhou = false;
	    uint premio;
	    
	    if( (resultado[0] == resultado[1]) && (resultado[1] == resultado[2]) )
	    {
	        premio = premios[ resultado[0] ] * premiosGanhos[tx.origin];
	        ganhou = true;
	        
	        FCHContract.approve( tx.origin, premio );
	    }
	    else
	    {
	        premiosGanhos[tx.origin] = 0;
            status[tx.origin] = 0;
	    }
        
        return (resultado, ganhou);
	}
		
}