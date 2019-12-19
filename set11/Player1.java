//Constructor template for Player1:
//Player1(String s)
//Static Factory method make(String s) uses this Constructor to return a 
//Player1 object
//Interpretation: Player represents one of the Player1 of the RosterWithStream

public class Player1 implements Player
{
	private String name;      		   //name of the player
	private Boolean contractStatus;    //contract status of the player
	private Boolean injureStatus;      //injury status of the player
	private Boolean suspendStatus;     //suspended status of the player
	
	public Player1(String s) 
	{	
		name = s;
		contractStatus = true;
		injureStatus = false;
		suspendStatus = false;
	}
	
	//GIVEN: no argument
	//RETURNS: Returns the name of this player.
	//Players.make("Gordon Wayhard").name()  =>  "Gordon Wayhard"	

	public String name()
	{
		return name;
	}
	
	//GIVEN: no argument
    //RETURNS: true iff this player is
    //under contract and not injured and not suspended
    // Player gw = Players.make ("Gordon Wayhard");
    // System.out.println (gw.available());  // prints true	

	public boolean available() 
	{
		Boolean flag = false;
		
		if (underContract() &&
			(!isInjured()) &&
			(!isSuspended()))
			{
				flag = true;
			}
		
		return flag;
	}
	
	//GIVEN: no argument
	//RETURNS: Returns true iff this player is under contract (employed).
    //EXAMPLE: Player ih = Players.make ("Isaac Homas");
    //         System.out.println (ih.underContract());  // prints true		

	public boolean underContract() 
	{
		return contractStatus;
	}
	
	//GIVEN: no argument
	//RETURNS: true iff this player is injured.
    //EXAMPLE: Player ih = Players.make ("Isaac Homas");
    //         System.out.println (ih.isInjured());  // prints false		

	public boolean isInjured() 
	{
		return injureStatus;
	}

	//GIVEN: no argument
	//RETURNS: true iff this player is suspended.
    //EXAMPLE: Player ih = Players.make ("Isaac Homas");
    //         System.out.println (ih.isSuspended());  // prints false
	
	public boolean isSuspended() 
	{
		return suspendStatus;
	}
	
	//GIVEN: no argument
	//RETURNS: Changes the underContract() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeContractStatus(false)
    //         System.out.println (ih.underContract());  // prints false

	public void changeContractStatus(boolean newStatus) 
	{
		contractStatus = newStatus;
	}

	//GIVEN: no argument
	//RETURNS: Changes the isInjured() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeInjuryStatus(true)
    //         System.out.println (ih.isInjured());  // prints true	
	
	public void changeInjuryStatus(boolean newStatus) 
	{
		injureStatus = newStatus;		
	}

	//GIVEN: no argument
	//RETURNS: Changes the isSuspended() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeSuspendedStatus(true)
    //         System.out.println (ih.isSuspended());  // prints true	
	
	public void changeSuspendedStatus(boolean newStatus) 
	{
		suspendStatus = newStatus;
	}	

}
