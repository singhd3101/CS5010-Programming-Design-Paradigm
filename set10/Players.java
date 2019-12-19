//Constructor template for Players:
//Players(String s)
//Static Factory method make(String s) uses this Constructor to return a 
//Players object
//Interpretation: Player represents one of the Players of the Roster

public class Players implements Player
{
	private String pname;         //name of the player
	private Boolean pcontract;    //contract status of the player
	private Boolean pinjure;      //injury status of the player
	private Boolean psuspend;     //suspended status of the player
	
	private Players(String s) 
	{
		pname = s;
		pcontract = true;
		pinjure = false;
		psuspend = false;
	}
	
	//GIVEN: a String
	//RETURNS: the a static factory method that returns
    // a player with the given name who is (initially) available.
	//EXAMPLE: Player.make("A") => new Player("A")
	
	public static Player make(String s)
	{
		Player p = new Players(s);
		
		return p;
	}
	
	//GIVEN: no argument
	//RETURNS: Returns the name of this player.
	//Players.make("Gordon Wayhard").name()  =>  "Gordon Wayhard"	

	public String name()
	{
		return pname;
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
		return pcontract;
	}
	
	//GIVEN: no argument
	//RETURNS: true iff this player is injured.
    //EXAMPLE: Player ih = Players.make ("Isaac Homas");
    //         System.out.println (ih.isInjured());  // prints false		

	public boolean isInjured() 
	{
		return pinjure;
	}

	//GIVEN: no argument
	//RETURNS: true iff this player is suspended.
    //EXAMPLE: Player ih = Players.make ("Isaac Homas");
    //         System.out.println (ih.isSuspended());  // prints false
	
	public boolean isSuspended() 
	{
		return psuspend;
	}
	
	//GIVEN: no argument
	//RETURNS: Changes the underContract() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeContractStatus(false)
    //         System.out.println (ih.underContract());  // prints false

	public void changeContractStatus(boolean newStatus) 
	{
		pcontract = newStatus;
	}

	//GIVEN: no argument
	//RETURNS: Changes the isInjured() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeInjuryStatus(true)
    //         System.out.println (ih.isInjured());  // prints true	
	
	public void changeInjuryStatus(boolean newStatus) 
	{
		pinjure = newStatus;		
	}

	//GIVEN: no argument
	//RETURNS: Changes the isSuspended() status of this player
    // to the specified boolean.
    //EXAMPLE: ih.changeSuspendedStatus(true)
    //         System.out.println (ih.isSuspended());  // prints true	
	
	public void changeSuspendedStatus(boolean newStatus) 
	{
		psuspend = newStatus;
	}	

}
