// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <link>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.

contract FICHAInterface
{
    function myBalance() external constant returns	(uint balance);
	function transfer(address _to,	uint _value) external returns (bool success);
	function transferFrom(address _from, address _to, uint _value) external returns (bool success);
	function approve(address _spender,	uint _value) public returns (bool success);
} 

contract JogoCassino
{
    address owner;
	
	address FCHAddress = 0x6e9d5ecb69de32b17b6212cab20ca91272f0f592;
    FICHAInterface FCHContract = FICHAInterface(FCHAddress);
    
    constructor() public 
	{
		owner =  msg.sender;
    }	

	modifier onlyOwner 
	{
		require(tx.origin == owner, "Somente o dono do contrato pode invocar essa função!");
		_;
	}
	
	function alterarContratoToken(address novoEndereco) external onlyOwner
	{
	    FCHAddress = novoEndereco;
	    FCHContract = FICHAInterface(FCHAddress);
	}
	
	function transferirTudoParaDono() external onlyOwner
	{
	    uint balance = FCHContract.myBalance();
	    
	    FCHContract.approve(owner, balance );
	    FCHContract.transferFrom(address(this), owner, balance);
	}
}