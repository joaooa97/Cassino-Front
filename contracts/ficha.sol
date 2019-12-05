// Nome: José Diogo Bezerra de Souza
// Conta do contrato: <https://ropsten.etherscan.io/address/0x6e9D5ecb69de32b17B6212caB20ca91272F0f592>

pragma  solidity  ^0.4.25; // Fique a vontade caso queira utilizar outra versão.

contract FICHA
{	
    string  name = "FICHA";
    string  symbol = "FCH";
    string  version = "0.1";
    
	address owner;
	uint supply;
	
    mapping(address	=>	uint256)	balances;	
    mapping	(address	=>	mapping	(address	=>	uint256))	public	allowed;
    
	event Transfer(address indexed _from,	address indexed _to,	uint _value);	
	event Approval(address indexed _owner,	address indexed _spender,	uint _value);
	
	constructor() public 
	{
		owner =  msg.sender;
	}

	modifier onlyOwner 
	{
		require(msg.sender == owner, "Somente o dono do contrato pode invocar essa função!");
		_;
	}
	
	function mint(address _to, uint256 _amount) public
	{
        require(msg.sender == owner);
        balances[_to] += _amount;
        supply += _amount;
        emit Transfer(address(0), _to, _amount);
    } 
    
	function totalSupply() public constant returns (uint theTotalSupply)
	{
	    return supply;
	}
	
	function balanceOf(address _owner) external constant returns	(uint balance)
	{
	    return balances[_owner];
	}
	
	function myBalance() external constant returns	(uint balance)
	{
	    return balances[msg.sender];
	}
	
	function transfer(address _to,	uint _value) external returns (bool success)
	{
	    if( balances[tx.origin] >= _value )
	    {
	        balances[tx.origin] -= _value;
	        balances[_to]        += _value;
	        
            emit Transfer(tx.origin, _to, _value);
            return true;
	    }
	    else
	    {
            return false;
	    }
	}

	function transferFrom(address _from, address _to, uint _value) external returns (bool success)
	{
        if( allowed[_from][_to] >= _value )
	    {
            if( balances[_from] >= _value )
    	    {
    	        balances[_from]     -= _value;
    	        allowed[_from][_to] -= _value;
    	        
    	        balances[_to]   += _value;
    	        
                emit Transfer(_from, _to, _value);
                return true;
    	    }
    	    else
    	    {
                return false;
    	    }
	    }
	    else
	    {
	        return false;
	    }
	}
	
	function approve(address _spender,	uint _value) public returns (bool success)
	{
	    if( balances[msg.sender] >= _value )
	    {
	        allowed[msg.sender][_spender] = _value;
            emit Approval(msg.sender, _spender, _value);
            return true;
	    }
	    else
	    {
	        return false;
	    }
	}
	
	function allowance(address _owner,	address _spender) external constant returns (uint remaining)
	{
	    return allowed[_owner][_spender];
	}
		
}