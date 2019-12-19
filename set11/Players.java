//Constructor template for Players:
//Players()
//Interpretation: Player represents one of the Players of the RosterWithStream

public class Players {
	
	//GIVEN: a String
	//RETURNS: the a static factory method that returns
	// a player with the given name who is (initially) available.
	//EXAMPLE: Player.make("A") => new Player("A")
	
	public static Player make(String s)
	{
		return new Player1(s);
	}

}
