// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <https://ropsten.etherscan.io/address/0x782977207a16cDC1Eb56A6923D69Eb15D9EF5ffA>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.
pragma experimental ABIEncoderV2;

import "./jogo_cassino.sol";

contract Loteria is JogoCassino
{	
    uint private bilheteValue = 50;
    
    // Valores dinamicos causando problemas.
    // uint quantidadeNumerosChamar = 100
    // uint tamanhoBilhete = 10
    
    address[] private bilhetesComprados;
    mapping (address => uint8[][] ) private bilhetesPorUsuario;
    mapping (bytes32 => address[] ) private usuarioPorBilhete;
    
    address[] private ganhadores;
    mapping (address => uint) private premioPorGanhador;
    
    event novoBilheteComprado(address comprador);
    event novoBilheteSorteado(address comprador);

    function comprarBilhete(uint8[5] bilhete) external returns (bool)
    {
        // Inserir o valor na carteira de tokens da loteria.
        require( FCHContract.transfer( address(this), bilheteValue ) , "Você não tem saldo suficiente para comprar um bilhete." );
        
        bool naoComprou = false;
        
        uint8 i;
        
        for(i = 0; i < bilhetesComprados.length; i++)
        {
            if( bilhetesComprados[i] == tx.origin )
            {
                naoComprou = true;
            }
        }
            
        if( !naoComprou )
            bilhetesComprados.push(tx.origin);
            
        
        usuarioPorBilhete[keccak256(abi.encodePacked(bilhete))].push(tx.origin);
        bilhetesPorUsuario[tx.origin].push( bilhete );
        
        emit novoBilheteComprado(tx.origin);
        
        return naoComprou;
    }
    
    function retornarPremio() public view returns (uint)
    {
	    return FCHContract.myBalance() / 2;
    }
    
    function meusBilhetes() external view returns ( uint8[][] )
    {
        return bilhetesPorUsuario[tx.origin];
    }
    
    function randomNumber(uint8 seed, uint8 limit) private view returns (uint8)
    {
       return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, now, seed)))%limit);
    }
    
    function sortear() external onlyOwner returns (address[], uint8[5], uint)
    {
        uint8[5] memory numerosChamados;
        
        uint8 i;
        
        for( i = 0; i < 5; i++)
        {
            numerosChamados[i] = randomNumber(i, 5);
        }
        
        ganhadores = usuarioPorBilhete[ keccak256(abi.encodePacked(numerosChamados)) ];
        
        // Dividir o premio caso haja mais de um ganhador;
        
        uint qtdGanhadores = ganhadores.length;
        uint premio = (FCHContract.myBalance() / 2);
        
        if( qtdGanhadores > 0 )
        {
            premio = (premio / qtdGanhadores);
            
            for( i = 0; i < qtdGanhadores; i++ )
            {
                premioPorGanhador[ganhadores[i]] = premio;
                FCHContract.approve( ganhadores[i], premio );
                FCHContract.transferFrom( address(this), ganhadores[i], premio );
            }
        }
        
        // Limpar todos os dados após o sorteio.
        
        for( i = 0; i < bilhetesComprados.length; i++)
        {
            delete bilhetesPorUsuario[bilhetesComprados[i]];
        }
        
        delete bilhetesComprados;
        
        return (ganhadores,numerosChamados, premio);
    }
    
    function sacarPremio() external returns (uint) 
    {
        bool isGanhador = false;
        
        for( uint8 i = 0; i < ganhadores.length; i++)
        {
            if( tx.origin == ganhadores[i] )
            {
                isGanhador = true;
                ganhadores[i] = 0;
            }
        }
        
        require(isGanhador, "Você precisa ter ganho para sacar o premio.");
        
        FCHContract.transferFrom( address(this), tx.origin, premioPorGanhador[tx.origin] );
        
        uint premio = premioPorGanhador[tx.origin];
        premioPorGanhador[tx.origin] = 0;
        
        return premio;
    }	
}