//Constructor template for Tie1:
//new Tie1 (Competitor c1, Competitor c2)
//Interpretation:
//c1 and c2 have engaged in a contest that ended in a tie

public class Tie1 implements Outcome {

	String comp1 = "";
	String comp2 = "";
	Competitor c1 = new Competitor1(comp1); // Competitor 1 in the outcome
	Competitor c2 = new Competitor1(comp2); // Competitor 2 in the outcome

	Tie1(Competitor c1, Competitor c2) {

		this.c1 = c1;
		this.c2 = c2;

	}

	// GIVEN: no arguments
	// RETURNS: true iff this outcome represents a tie
	// EXAMPLE: (new Tie1(A,B)).isTie() => True

	public boolean isTie() {

		return true;

	}

	// GIVEN: no arguments
	// RETURNS: one of the competitors
	// EXAMPLE: (new Tie1(A,B)).first() => A

	public Competitor first() {

		return this.c1;

	} 

	// GIVEN: no arguments
	// RETURNS: the other competitor
	// EXAMPLE: (new Tie1(A,B)).second() => B

	public Competitor second() {

		return this.c2;
 
	}

	// GIVEN: no arguments
	// WHERE: this.isTie() is false
	// RETURNS: Unsupported exception for Tie Outcome
	// EXAMPLE: (new Tie1(A,B)).winner() => UnsupportedOperationException

	public Competitor winner() {

		throw new UnsupportedOperationException();

	}

	// GIVEN: no arguments
	// WHERE: this.isTie() is false
	// RETURNS: Unsupported exception for Tie Outcome
	// EXAMPLE: (new Tie1(A,B)).loser() => UnsupportedOperationException

	public Competitor loser() {

		throw new UnsupportedOperationException();

	}
}
