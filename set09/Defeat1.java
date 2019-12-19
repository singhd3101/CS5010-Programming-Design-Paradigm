//Constructor template for Defeat1:
//new Defeat1 (Competitor c1, Competitor c2)
//Interpretation:
//c1 and c2 have engaged in a contest that ended with
//  c1 defeating c2

public class Defeat1 implements Outcome 
{ 

	String comp1 = "";
	String comp2 = "";
	Competitor c1 = new Competitor1(comp1);    // Competitor 1 in the outcome
	Competitor c2 = new Competitor1(comp2);	   // Competitor 2 in the outcome

	Defeat1(Competitor c1, Competitor c2) 
	{
    	this.c1 = c1;
		this.c2 = c2;
    }

	// GIVEN: no arguments
	// RETURNS: true iff this outcome represents a tie
	// EXAMPLE: (new Defeat1(A,B)).isTie() => False

	public boolean isTie() {

		return false;

	}

	// GIVEN: no arguments
	// RETURNS: one of the competitors
	// EXAMPLE: (new Defeat1(A,B)).first() => "A"

	public Competitor first() {

		return this.c1;

	}

	// GIVEN: no arguments
	// RETURNS: the other competitor
	// EXAMPLE: (new Defeat1(A,B)).second() => B

	public Competitor second() {

		return this.c2;

	}

	// GIVEN: no arguments
	// WHERE: this.isTie() is false
	// RETURNS: the loser of this outcome
	// EXAMPLE: (new Defeat1(A,B)).winner() => A

	public Competitor winner() {

		return this.c1;

	}

	// GIVEN: no arguments
	// WHERE: this.isTie() is false
	// RETURNS: the loser of this outcome
	// EXAMPLE: (new Defeat1(A,B)).loser() => B

	public Competitor loser() {

		return this.c2;

	}
}
