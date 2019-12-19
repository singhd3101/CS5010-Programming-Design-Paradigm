//Constructor template for Competitor1:
//new Competitor1 (String s)
//
//Interpretation: the competitor represents an individual or team

//Note:  In Java, you cannot assume a List is mutable, because all
//of the List operations that change the state of a List are optional.
//Mutation of a Java list is allowed only if a precondition or other
//invariant says the list is mutable and you are allowed to change it.

import java.util.*;
import java.util.stream.Collectors;

class Competitor1 implements Competitor {

	// Represents one of the Competitor
	String comp1 = "";   
	
	// Represents that the Competitor won or tied in the outcome
	String ADD = "add";   
	
	// Represents that the Competitor lost in the outcome
	String LOST = "lost"; 
	
	Competitor1(String s) 
	{
		this.comp1 = s;
	}

	// GIVEN: no arguments
	// RETURNS the name of this competitor
	// EXAMPLE: (new Competitor("A")).name() => "A"

	public String name() 
	{
		return this.comp1;
	}

	// GIVEN: another competitor and a list of outcomes
	// RETURNS: true iff one or more of the outcomes indicates this
	// competitor has defeated or tied the given competitor
	// EXAMPLE: A.hasDefeated(B,(new Defeat1(A,B)) => True

	public boolean hasDefeated(Competitor c2, List<Outcome> outcomes) 
	{
		Boolean result = false; // Variable to store result

		if (outcomes.isEmpty()) 
		{
			return result;
		} 
		else 
		{
			// Local variable for filtered list of defeat outcomes from total 
			// outcomes
			List<Outcome> dlist = new ArrayList<Outcome>();
			
			// Local variable for filtered list of tie outcomes from total 
			//outcomes
			List<Outcome> tlist = new ArrayList<Outcome>();
			
			dlist = fetchDefeatOutcomes(outcomes);
			tlist = fetchTieOutcomes(outcomes);

			if (checkDefeatedOutcome(c2, dlist))
			{
				result = true;
			} 
			else 
			{
				result = checkTieOutcome(c2, tlist);
			}
		}
		return result;
	}

	// GIVEN: a list of outcomes
	// RETURNS: a list of the names of all competitors mentioned by
	// the outcomes that are outranked by this competitor,
	// without duplicates, in alphabetical order
	// STRATEGY: Initialization of invariant plst for outranksList
	//          method
	// EXAMPLE: (A.outranks(new Defeat(A,B)) => [B]

	public List<String> outranks(List<Outcome> outcomes) 
	{	
		
		//Local variable to store output of outranksList method
		List<String> lst = new ArrayList<String>();
		
		//Invariant to store List of Competitor names. 
		List<String> plst = new ArrayList<String>();
		
		if (outcomes.isEmpty())
		{
			return lst;
		}
		else
		{
			lst = outranksList(this.comp1, outcomes,plst);
		}
		
		Collections.sort(lst);
		
		return uniqueList(lst);
	}
	
	// GIVEN: a list of outcomes
	// RETURNS: a list of the names of all competitors mentioned by
	// the outcomes that outrank this competitor,
	// without duplicates, in alphabetical order
	// STRATEGY: Initialization of invariant plst for outrankedByList
    //           method
	// EXAMPLE: (B.outrankedBy(new Defeat(A,B)) => [A]

	public List<String> outrankedBy(List<Outcome> outcomes) 
	{
		//Local variable to store output of outrankedByList method
		List<String> lst = new ArrayList<String>();
		
		//Invariant to store List of Competitor names
		List<String> plst = new ArrayList<String>();
		
		if (outcomes.isEmpty())
		{
			return lst;
		}
		else
		{
			lst = outrankedByList(this.comp1, outcomes,plst);
		}
		
		Collections.sort(lst);
		
		return uniqueList(lst);

	}

	// GIVEN: a list of outcomes
	// RETURNS: a list of the names of all competitors mentioned by
	// one or more of the outcomes, without repetitions, with
	// the name of competitor A coming before the name of
	// competitor B in the list if and only if the power-ranking
	// of A is higher than the power ranking of B.
	// STRATEGY: Initialization of invariant slist for rankings
    //           method
	// EXAMPLE: (A.powerRanking(new Defeat1(A,B))) => [A,B]

	public List<String> powerRanking(List<Outcome> outcomes) 
	{
		//Local variable to store output of outrankedByList method
		List<String> result = new ArrayList<String>();
		
		//Invariant to store List of PlayerScores
		List<PlayerScore> slist = new ArrayList<PlayerScore>();

		if(outcomes.isEmpty())
		{
			return result;
		}
		else
		{
			result = fetchNames (sortByRanking (rankings (outcomes,slist)));
		}
		
		return result;
	}
	
	// GIVEN: a list of outcomes and a Competitor
	// RETURNS: the number of Competitors the given Competitor outranks
	// STRATEGY: Initialization of invariant plst for outranksList
	//           method
	// EXAMPLE: (A.countOutranks(new Defeat(A,B)) => 1
	
	public int countOutranks(String c1,List<Outcome> outcomes) 
	{	
		//Local variable to store output of outranksList method
		List<String> lst = new ArrayList<String>();
		
		//Invariant to store List of Competitor names
		List<String> plst = new ArrayList<String>();
		
		if (outcomes.isEmpty())
		{
			return 0;
		}
		else
		{
			lst = outranksList(c1, outcomes,plst);
		}
		
		Collections.sort(lst);
		
		return uniqueList(lst).size();
	}
	
	// GIVEN: a list of outcomes and a Competitor
	// RETURNS: the number of Competitors that outrank the given Competitor
	// STRATEGY: Initialization of invariant plst for outranksList
	//           method
	// EXAMPLE: (B.countOutrankedBy(new Defeat(A,B)) => 1

	public int countOutrankedBy(String c1,List<Outcome> outcomes) 
	{
		//Local variable to store output of outranksList method
		List<String> lst = new ArrayList<String>();
		
		//Invariant to store List of Competitor names
		List<String> plst = new ArrayList<String>();
		
		if (outcomes.isEmpty())
		{
			return 0;
		}
		else
		{
			lst = outrankedByList(c1, outcomes,plst);
		}
		
		Collections.sort(lst);
		
		return uniqueList(lst).size();
	}
	
	// GIVEN: a list of PlayerProfiles
	// RETURNS: the number of Competitors from the list of PlayerProfiles
	// EXAMPLE: (B.fetchNames(new PlayerProfile(F 2 16 1.0)) => [F]
	
	public List<String> fetchNames(List<PlayerProfile> lst) 
	{
		//Local variable to store output
		List<String> powerRanking = new ArrayList<String>();
		
		for(int i = 0; i< lst.size(); i++)
		{
			powerRanking.add(lst.get(i).getName());
		}
		
		Collections.reverse(powerRanking);
		
		return powerRanking;
	}

	// GIVEN: a list of PlayerProfiles
	// RETURNS: a sorted list of PlayerProfiles based on PlayerProfile 
	//          attributes
	// EXAMPLE: (B.sortByRanking(new PlayerProfile(F 3 3 0.5)
	//           ,(new PlayerProfile(Q 3 3 1.0)) => 
	//           [(new PlayerProfile(Q 3 3 1.0) (new PlayerProfile(F 3 3 0.5)]
	
	private List<PlayerProfile> sortByRanking(List<PlayerProfile> rankings) 
	{	
		rankings.sort( (p1, p2) -> 
		{
			if (checkOutrankedCondition (p1, p2))
			{
				return 1;
			}
			else if (checkOutranksCondition(p1, p2))
			{
				return 1;
			}
			else if (checkPercCond (p1, p2))
			{
				return 1;
			}
			else if (checkNameCond (p1, p2))
			{
				return 1;
			}
			else
			{
				return -1;
			}
		});
		
		return rankings;
	}

	// GIVEN: two PlayerProfiles
	// RETURNS: true iff for equal no of outranks, outrankedby and non-losing 
	//          percentage, name of name of Competitors occur in alphabetical
	//          order in PlayerProfiles
	// EXAMPLE: (B.checkNameCond(new PlayerProfile(F 3 3 1),
	//           new PlayerProfile(G 3 3 1)) => true
	
	public boolean checkNameCond(PlayerProfile p1, PlayerProfile p2) 
	{
		if ((p1.getNoOutranked() == p2.getNoOutranked()) &&
				(p1.getNoOutranks() == p2.getNoOutranks()) &&
				(p1.getPerc() == p2.getPerc()))
		{
			if (p1.getName().compareTo(p2.getName()) < 0)
			{
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
	
	// GIVEN: two PlayerProfiles
	// RETURNS: true iff for equal number of outranks and outrankedBy, the 
	//          first Competitor has greater non-losing percentage
	//          than the other
	// EXAMPLE: (B.checkPercCond(new PlayerProfile(F 3 3 1),
	//           new PlayerProfile(G 3 3 0.5)) => true

	public boolean checkPercCond(PlayerProfile p1, PlayerProfile p2) 
	{
		if ((p1.getNoOutranked() == p2.getNoOutranked()) &&
				(p1.getNoOutranks() == p2.getNoOutranks()) &&
				(p1.getPerc() > p2.getPerc()))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	// GIVEN: two PlayerProfiles
	// RETURNS: true iff for equal number of outrankedBy, the no of outranks 
	//          for first Competitor is greater than the other
	// EXAMPLE: (B.checkOutranksCondition(new PlayerProfile(F 4 3 1),
	//           new PlayerProfile(G 3 3 1)) => true

	private boolean checkOutranksCondition(PlayerProfile p1, PlayerProfile p2) 
	{
		if((p1.getNoOutranked() == p2.getNoOutranked()) && 
				(p1.getNoOutranks() > p2.getNoOutranks()))
		{
			return true;
		}
		else
		{
			return false;
		}		
	}

	// GIVEN: two PlayerProfiles
	// RETURNS: true iff for equal number of outrankedBy, for first Competitor
	//          is greater than the other
	// EXAMPLE: (B.checkOutrankedCondition(new PlayerProfile(F 3 4 1),
	//           new PlayerProfile(G 3 4 1)) => true	
	
	public boolean checkOutrankedCondition(PlayerProfile p1,
			PlayerProfile p2) 
	{
		if (p1.getNoOutranked() < p2.getNoOutranked())
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	// GIVEN: a list of Outcomes and a list of PlayerScores
	// RETURNS: list of PlayerProfiles of all the Competitors from the list of
	//          outcomes
	// EXAMPLE: (B.rankings(new Defeat1(A,B),[])) => 
	//          [(new PlayerProfile(A 1 0 1) (new PlayerProfile(B 0 1 0)]

	public List<PlayerProfile> rankings(List<Outcome> outcomes, 
			List<PlayerScore> slist) 
	{
		// Local variable to store the output of method calculateRanking
		List<PlayerProfile> profileLst = new ArrayList<PlayerProfile>();
		
		// Local variable to store the output of method totalPlayers
		List<PlayerScore> lst = new ArrayList<PlayerScore>();
		
		lst = totalPlayers(outcomes,slist);
		
		profileLst = calculateRanking(outcomes, lst);
		
		return profileLst;
	}
	
	// GIVEN: a list of Outcomes and a list of PlayerScores
	// RETURNS: list of PlayerProfiles of all the Competitors from the list of
	//          outcomes
	// EXAMPLE: (B.calculateRanking(new Defeat1(A,B),[])) => 
	//          [(new PlayerProfile(A 1 0 1) (new PlayerProfile(B 0 1 0)]
	
	public List<PlayerProfile> 
	calculateRanking(List<Outcome> outcomes, List<PlayerScore> slist)
	{
		// Local variable to PlayerProfiles form the method createProfile
		List<PlayerProfile> plist = new ArrayList<PlayerProfile>();
		
		for(int i = 0; i <slist.size(); i++)
		{
			plist.add(createProfile(slist.get(i), outcomes));
		}
		
		return plist;
	}

	// GIVEN: a PlayerScore and a list of Outcomes
	// RETURNS: a PlayerProfile created from from the list of outcomes and
	//          PlayerScore for the Competitor present in PlayerScore
	// EXAMPLE: (B.createProfile(new PlayerScore(A 0 1),[new Defeat1(A,B)])) => 
	//          [(new PlayerProfile(A 1 0 1)]
	
	public PlayerProfile createProfile(PlayerScore s, List<Outcome> outcomes)
	{
		PlayerProfile p = new PlayerProfile();
		
		p.setName(s.getName());
		p.setNoOutranks(countOutranks(s.getName(),outcomes));
		p.setNoOutranked(countOutrankedBy(s.getName(),outcomes));
		p.setPerc(calculatePerc(s));
		
		return p;
	}
	
	// GIVEN: a PlayerScore
	// RETURNS: the non-losing percentage for the Competitor present in 
	//          PlayerScore
	// EXAMPLE: (B.calculatePerc(new PlayerScore(A 0 1))) => 1
	
	public double calculatePerc(PlayerScore s)
	{
		double percentage = 0.0;
		
		percentage = 1 - ((double)s.getLost()/(double)s.getTotal());
		
		return percentage;
	}
	
	// GIVEN: a list of outcomes and a list of PlayerScore
	// RETURNS: a list of PlayerScore of all the competitors who are present
	//          in OutcomeList
	// EXAMPLE: (B.totalPlayers([(new Defeat1(A,B) (new Defeat1(B,C))
	//          (new Tie1(B,E))] => [(new PlayerScore(E 0 1) 
	//          (new PlayerScore(C 1 1) (new PlayerScore(A 0 1)
	//          (new PlayerScore(B 1 3)]

	public List<PlayerScore> totalPlayers(List<Outcome> lst, 
			List<PlayerScore> slist)
	{
		
		//Local variable to store the output of extractPlayer method
		List<PlayerScore> result = new ArrayList<PlayerScore>();
		
		for(int i = 0; i<lst.size() ; i++)
		{
			result = extractPlayer(lst.get(i),slist);
		}
		
		return result;
	}
	
	// GIVEN: an outcome and a list of PlayerScores
    // RETURNS: updated PlayerScore list with the Competitors present in
	//          the input outcome
	// EXAMPLE: (B.extractPlayer((new Defeat1(A,B) []) => 
	//         [(new PlayerScore(A 0 1)) (new PlayerScore(B 1 1))]
	
	public List<PlayerScore> extractPlayer(Outcome o,List<PlayerScore> slist)
	{
		// Local variable to store output of isPlayerPresentTie 
		// or isPlayerPresentDefeat method
		List<PlayerScore> result = new ArrayList<PlayerScore>();
		
		if (o.isTie())
		{
			result = isPlayerPresentTie(o,slist);
		}
		else
		{
			result = isPlayerPresentDefeat(o,slist);
		}
		
		return result;
	}
	
	// GIVEN: an outcome and a list of PlayerScores
    // RETURNS: updated PlayerScore list with the Competitors present in
	//          the input outcome
	// EXAMPLE: (B.isPlayerPresentTie((new Tie1(B,E) [(new PlayerScore(C 1 1)
	//           (new PlayerScore(A 0 1) (new PlayerScore(B 1 2)]) => 
	//         [(new PlayerScore(E 0 1)) (new PlayerScore(C 1 1))
	//           (new PlayerScore(A 0 1)) (new PlayerScore(B 1 3))]
	
	public List<PlayerScore> isPlayerPresentTie(Outcome o,
			List<PlayerScore> slist)
	{
		// Local variable to store the output of isPlayerPresent method
		List<PlayerScore> result = new ArrayList<PlayerScore>();
		
		String state = "";
		
		state = ADD;
		
		result = isPlayerPresent(o.first(),state,slist);
		
		result = isPlayerPresent(o.second(),state,result);
		
		return result;
	}
	
	// GIVEN: an outcome and a list of PlayerScores
    // RETURNS: updated PlayerScore list with the Competitors present in
	//          the input outcome
	// EXAMPLE: (B.isPlayerPresentDefeat((new Defeat1(A,B) []) =>
	//          [(new PlayerScore(A 0 1)) (new PlayerScore(B 1 1))]
	
	public List<PlayerScore> isPlayerPresentDefeat(Outcome o,
			List<PlayerScore> slist)
	{
		// Local variable to store the output of isPlayerPresent method
		List<PlayerScore> result = new ArrayList<PlayerScore>();
		
		String state = "";
		
		state = ADD;
		
		result = isPlayerPresent(o.winner(),state,slist);
		
		state = LOST;
				
		result = isPlayerPresent(o.loser(),state,result);
		
		return result;
	}
	
	// GIVEN: a Competitor, state of Competitor and PlayerScore list
    // RETURNS: updated PlayerScore list with the Competitors present in
	//          the input Competitor
	// EXAMPLE: (B.isPlayerPresent(B "lost" []) =>
	//          [(new PlayerScore(B 1 1))]	
	
	public List<PlayerScore> isPlayerPresent(Competitor c, String state, 
			List<PlayerScore> slist)
	{
		// Local variable to store output of addFunc or lostFunc methods
		List<PlayerScore> result = new ArrayList<PlayerScore>();
		
		if (matchFunc(c,slist))
		{
			result = changeScore(c,state,slist);
		}
		else
		{
			PlayerScore obj = new PlayerScore();
			obj.setName(c.name());
			
			if(state == ADD)
			{
				slist.add(addFunc(obj));
				result = slist;
			}
			else
			{
				slist.add(lostFunc(obj));
				result = slist;
			}
		}
		
		return result;
	}

	// GIVEN: a Competitor and PlayerScore list
    // RETURNS: true iff the given Competitor is present in the input 
	//          PlayerScore List
	// EXAMPLE: (B.matchFunc(B []) => false	
	
	public Boolean matchFunc(Competitor c, List<PlayerScore> slist)
	{
		Boolean flag = false;
		
		for(int i = 0; i<slist.size(); i++)
		{
			if (c.name() == slist.get(i).getName())
			{
				flag = true;
			}			
		}		
		return flag;
	}
	
	// GIVEN: a Competitor, state of the Competitor and PlayerScore list
    // RETURNS: updated PlayerScoreList with the given Competitor based on
	//          its state
	// EXAMPLE: (B.changeScore(B "ADD" [(new PlayerScore(B 1 1))]) => 
    //           		[(new PlayerScore(B 1 2))])
	
	public List<PlayerScore> changeScore(Competitor c, String state,
			List<PlayerScore> slist)
	{
		for(int i =0; i< slist.size();i++)
		{
			if(c.name() == slist.get(i).getName())
			{
				if (state == ADD)
				{
					slist.set(i, addFunc(slist.get(i)));
				}
				else
				{
					slist.set(i, lostFunc(slist.get(i)));
				}
			}
		}
		
		return slist;
	}
	
	// GIVEN: a PlayerScore
    // RETURNS: updated PlayerScore for the competitor present in it
	// EXAMPLE: (B.addFunc(new PlayerScore(B 1 1))) => 
    //           		(new PlayerScore(B 1 2))
	
	public PlayerScore addFunc(PlayerScore c)
	{
		PlayerScore obj = new PlayerScore();
		
		obj.setName(c.getName());
		obj.setLost(c.getLost());
		
		int t = c.getTotal() + 1;
		
		obj.setTotal(t); 
		
		return obj;
	}
	
	// GIVEN: a PlayerScore
    // RETURNS: updated PlayerScore for the competitor present in it
	// EXAMPLE: (B.lostFunc(new PlayerScore(B 1 1))) => 
    //           		(new PlayerScore(B 2 3))	
	
	public PlayerScore lostFunc(PlayerScore c)
	{
		PlayerScore obj = new PlayerScore();
		
		obj.setName(c.getName());
		
		int l = c.getLost() + 1;
		obj.setLost(l);
		
		int t = c.getTotal() + 1;
		obj.setTotal(t);
		
		return obj;
	}
	
	// GIVEN: a list of String
    // RETURNS: String list after removing duplicates
	// EXAMPLE: (B.uniqueList(["A" "A" "B"]) => ["A" "B"] 

	public List<String> uniqueList(List<String> lst)
	{
		return lst.stream().distinct().collect(Collectors.toList());
	}

	// GIVEN: a Competitor and a list of Defeat outcomes
    // RETURNS: true iff first competitor has defeated the second Competitor
	//          in the list of input outcomes
	// EXAMPLE: (A.checkDefeatedOutcome(B, (new Defeat1(A,B))) => true 	
	
	public boolean checkDefeatedOutcome(Competitor c2, List<Outcome> dlist) 
	{
		Boolean flag = false;

		if (dlist.isEmpty())
		{
			flag = false;
		} 
		else
		{
			Iterator<Outcome> itr = dlist.iterator();

			while (itr.hasNext()) {
				Outcome o = itr.next();
				if ((this.comp1 == o.winner().name()) && 
						(c2.name() == o.loser().name())) {
					flag = true;
				}
			}
		}

		return flag;
	}

	// GIVEN: a Competitor and a list of Defeat outcomes
    // RETURNS: true if and only if one or more of the outcomes indicates
	//          the first competitor has tied with the second
	//          in the list of input outcomes
	// EXAMPLE: (A.checkTieOutcome(B, (new Tie1(A,B))) => true
	
	boolean checkTieOutcome(Competitor c2, List<Outcome> tlist) {
		Boolean flag = false;

		if (tlist.isEmpty())
		{
			flag = false;
		} 
		else 
		{
			Iterator<Outcome> itr = tlist.iterator();

			while (itr.hasNext()) 
			{
				Outcome o = itr.next();
				if ((this.comp1 == o.first().name()) && 
						(c2.name() == o.second().name()) ||
				    (c2.name() == o.first().name()) &&
				    (this.comp1 == o.second().name())) 
				{
					flag = true;
				}
			}
		}

		return flag;
	}
	
	// GIVEN: a list of outcomes
    // RETURNS: a list of Defeat outcomes extracted from the list of outcomes
	// EXAMPLE: (A.fetchDefeatOutcomes[(new Defeat1(A,B) (new Tie1(A,B)] => 
    //            [(new Defeat1(A,B)]
	
	List<Outcome> fetchDefeatOutcomes(List<Outcome> outcomes)
	{
		// Local variable to store Defeat outcomes
		List<Outcome> l = new ArrayList<Outcome>();
		
		Iterator<Outcome> itr = outcomes.iterator();
		while (itr.hasNext()) 
		{
			Outcome o = itr.next();
			if (!(o.isTie())) 
			{
				l.add(o);
			} 
		}
		
		return l;
	}
	
	// GIVEN: a list of outcomes
    // RETURNS: a list of Tie outcomes extracted from the list of outcomes
	// EXAMPLE: (A.fetchDefeatOutcomes[(new Defeat1(A,B) (new Tie1(A,B)] => 
    //            [(new Tie1(A,B)]	
	
	List<Outcome> fetchTieOutcomes(List<Outcome> outcomes)
	{
		// Local variable to store Tie outcomes
		List<Outcome> l = new ArrayList<Outcome>();
		
		Iterator<Outcome> itr = outcomes.iterator();
		while (itr.hasNext()) 
		{
			Outcome o = itr.next();
			if (o.isTie())
			{
				l.add(o);
			} 
		}
		
		return l;
	}
	
	// GIVEN: a Competitor name, list of outcomes, list of Competitor names
    // RETURNS: a list of Competitors outranked by the given Competitor
	// EXAMPLE: (A.outranksList[(new Defeat1(A,B)] => 
    //            ["B"]	
	
	List<String> outranksList(String c1, List<Outcome> lst, List<String> plst)
	{
		//Local variable to store output of createOutranksList method
		List<String> result = new ArrayList<String>();
		
		if (plst.contains(c1))
		{
			return result;
		}
		else
		{
			plst.add(c1);
			result = createOutranksList(c1, lst,plst);
		}
		
		return result;
	}
	
	// GIVEN: a Competitor name, list of outcomes, list of Competitor names
    // RETURNS: a list of Competitors outranked by the given Competitor
	// EXAMPLE: (A.createOutranksList("A", [(new Defeat1(A,B)] ["A"]) => 
    //            ["B"]
	
	List<String> createOutranksList(String c1, List<Outcome> lst, 
			List<String> plst)
	{
		//Local variable to store output of outranksByDefeat method
		List<String> defList = new ArrayList<String>();
		
		//Local variable to store output of outranksByTie method
        List<String> tieList = new ArrayList<String>();
        
        //Local variable to store output of fetchDefeatOutcomes method
        List<Outcome> defOutcomes = new ArrayList<Outcome>();
        
        //Local variable to store output of fetchTieOutcomes method
        List<Outcome> tieOutcomes = new ArrayList<Outcome>();
        
        defOutcomes = fetchDefeatOutcomes(lst);
        tieOutcomes = fetchTieOutcomes(lst);
        
		if (defOutcomes.isEmpty())
		{
			return defList;
		}
		else
		{
			defList = outranksByDefeat(c1,defOutcomes,lst,plst);
		}
		
		if (tieOutcomes.isEmpty())
		{
			return tieList;
		}
		else
		{
			tieList = outranksByTie(c1,tieOutcomes,lst,plst);
		}
		
		//Local variable to store appended list of defList and tieList
		List<String> appendList = new ArrayList<String>(defList);
		
		appendList.addAll(tieList);
		
		return appendList;
	}
	
	// GIVEN: a Competitor name, list of Defeat outcomes, a list of total
	//        outcomes and a list of Competitor names
    // RETURNS: a list of Competitors outranked by the given Competitor
    // HALTING MEASURE: Length of newlst
	// EXAMPLE: (A.outranksByDefeat("A", [(new Defeat1(A,B)],
	//          [(new Defeat1(A,B)] "A") => ["B"]
	
	List<String> outranksByDefeat(String c1, List<Outcome> newlst, 
			List<Outcome> oldlst, List<String> plst)
	{
		//Local variable to store result for Competitors outranked by 
		//given Competitor
		List<String> result = new ArrayList<String>();
		
		for (int i=0 ; i<newlst.size(); i++)
		{
			if (c1 == newlst.get(i).winner().name())
			{
				result.add(newlst.get(i).loser().name());
				result.addAll((outranksList(newlst.get(i).loser().name(), 
						oldlst,plst)));
			}
		}
		
		return result;
	}
	
	// GIVEN: a Competitor name, list of Tie outcomes, a list of total
	//        outcomes and a list of Competitor names
    // RETURNS: a list of Competitors outranked by the given Competitor
	// HALTING MEASURE: Length of newlst
	// EXAMPLE: (A.outranksByTie("A", [(new Tie1(A,B)],
	//          [(new Tie1(A,B)] "A") => ["A" "B"]
	
	List<String> outranksByTie(String c1, List<Outcome> newlst, 
			List<Outcome> oldlst,List<String> plst)
	{
		//Local variable to store result for Competitors outranked by 
		//given Competitor
		List<String> result = new ArrayList<String>();
		
		for (int i=0 ; i<newlst.size(); i++)
		{
			if (c1 == newlst.get(i).first().name() || 
					c1 == newlst.get(i).second().name())
			{
				result.add(newlst.get(i).first().name());
				result.add(newlst.get(i).second().name());
				if (c1 == newlst.get(i).first().name())
				{
					result.addAll((outranksList(newlst.get(i).second().name(), 
							oldlst,plst)));
				}
				else
				{
					result.addAll((outranksList(newlst.get(i).first().name(),
							oldlst,plst)));
				}
				
			}
		}
		
		return result;
	}

	// GIVEN: a Competitor name,a list of total and a list of Competitor names
    // RETURNS: a list of Competitors who outrank the given Competitor
	// EXAMPLE: (A.outrankedByList("A", [(new Defeat1(B,A)], []) => ["B"]
	
	public List<String> outrankedByList(String c1, List<Outcome> lst, 
			List<String> plst) 
	{
		//Local variable to store the output of createOutrankedList methid
		List<String> result = new ArrayList<String>();
		
		if (plst.contains(c1))
		{
			return result;
		}
		else
		{
			plst.add(c1);
			result = createOutrankedList(c1,lst,plst);
		}
		
		return result;
	}

	// GIVEN: a Competitor name,a list of total outcomes and a list of
	//        Competitor names
    // RETURNS: a list of Competitors who outrank the given Competitor
	// EXAMPLE: (A.createOutrankedList("A",[(new Defeat1(B,A)],["A"]) => ["B"]	
	
	public List<String> createOutrankedList(String c1, List<Outcome> lst,
			List<String> plst) 
	{
		//Local variable to store output of outrankedByDefeat method
		List<String> defList = new ArrayList<String>();
        
		//Local variable to store output of outrankedByTie method
		List<String> tieList = new ArrayList<String>();
		
		//Local variable to store output of fetchDefeatOutcomes method
        List<Outcome> defOutcomes = new ArrayList<Outcome>();
        
        //Local variable to store output of fetchTieOutcomes method
        List<Outcome> tieOutcomes = new ArrayList<Outcome>();
        
        defOutcomes = fetchDefeatOutcomes(lst);
        tieOutcomes = fetchTieOutcomes(lst);
        
		if (defOutcomes.isEmpty())
		{
			return defList;
		}
		else
		{
			defList = outrankedByDefeat(c1,defOutcomes,lst,plst);
		}
		
		if (tieOutcomes.isEmpty())
		{
			return tieList;
		}
		else
		{
			tieList = outrankedByTie(c1,tieOutcomes,lst,plst);
		}
		
		//Local variable to store appended list of defList and tieList
		List<String> appendList = new ArrayList<String>(defList);
		
		appendList.addAll(tieList);
		
		return appendList;
		
	}
	
	// GIVEN: a Competitor name,a list of Defeat outcomes, a list of total
	//        outcomes and a list of Competitor names
    // RETURNS: a list of Competitors who outrank the given Competitor
    // HALTING MEASURE: Length of newlst
	// EXAMPLE: (A.outrankedByDefeat("A",[(new Defeat1(B,A)],["A"]) => ["B"]	
	
	public List<String> outrankedByDefeat(String c1, List<Outcome> newlst,
			List<Outcome> oldlst, List<String> plst)
	{
		//Local variable to store output of outrankedByList method
		List<String> result = new ArrayList<String>();
		
		for (int i=0 ; i<newlst.size(); i++)
		{
			if (c1 == newlst.get(i).loser().name())
			{
				result.add(newlst.get(i).winner().name());
				result.addAll((outrankedByList(newlst.get(i).winner().name(),
						oldlst,plst)));
			}
		}
		
		return result;
	}
	
	// GIVEN: a Competitor name,a list of Tie outcomes, a list of total
	//        outcomes and a list of Competitor names
    // RETURNS: a list of Competitors who outrank the given Competitor
    // HALTING MEASURE: Length of newlst
	// EXAMPLE: (A.outrankedByDefeat("A",[(new Tie1(B,A)],["A"]) => ["B" "A"]	
	
	public List<String> outrankedByTie(String c1, List<Outcome> newlst, 
			List<Outcome> oldlst,List<String> plst)
	{
		//Local variable to store the result of outrankedByList method
		List<String> result = new ArrayList<String>();
		
		for (int i=0 ; i<newlst.size(); i++)
		{
			if (c1 == newlst.get(i).first().name() || 
					c1 == newlst.get(i).second().name())
			{
				result.add(newlst.get(i).first().name());
				result.add(newlst.get(i).second().name());
				if (c1 == newlst.get(i).first().name())
				{
			      result.addAll((outrankedByList(newlst.get(i).second().name(), 
			    		  oldlst,plst)));
				}
				else
				{
				  result.addAll((outrankedByList(newlst.get(i).first().name(),
						  oldlst,plst)));
				}
			}
		}
		
		return result;
	}

	
	public static void main(String[] args) {

		Competitor A = new Competitor1("A");
		Competitor B = new Competitor1("B");
		Competitor C = new Competitor1("C");
		Competitor D = new Competitor1("D");
		Competitor E = new Competitor1("E");
		Competitor F = new Competitor1("F");
		Competitor G = new Competitor1("G");
		Competitor H = new Competitor1("H");
		Competitor I = new Competitor1("I");
		Competitor J = new Competitor1("J");
		Competitor K = new Competitor1("K");
		Competitor L = new Competitor1("L");
		Competitor M = new Competitor1("M");
		Competitor N = new Competitor1("N");
		Competitor O = new Competitor1("O");
		Competitor P = new Competitor1("P");
		Competitor Q = new Competitor1("Q");
		Competitor R = new Competitor1("R");
		Competitor S = new Competitor1("S");
		Competitor T = new Competitor1("T");
		Competitor U = new Competitor1("U");
		Competitor V = new Competitor1("V");
		Competitor W = new Competitor1("W");
		Competitor X = new Competitor1("X");
		Competitor Y = new Competitor1("Y");
		Competitor Z = new Competitor1("Z");
		
		List<Outcome> testList = new ArrayList<Outcome>();
		
		// TC1
		
		testList.add(new Tie1(A,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Tie1(B,C));
		
		assert (A.hasDefeated(B, testList)) : "check1";
		
		testList.clear();
		
		//TC2
		
		testList.add(new Tie1(A,E));
		testList.add(new Defeat1(C,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Defeat1(A,C));
		testList.add(new Tie1(B,C));
		
		assert (!(A.hasDefeated(B, testList))) : "check2";
		
		testList.clear();
		
		//TC3
		
		testList.add(new Defeat1(C,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Defeat1(A,C));
		testList.add(new Tie1(B,C));
		
		List<String> sol = new ArrayList<String>();
		
		sol.add("A");
		sol.add("B");
		sol.add("C");
		
		assert ((A.outranks(testList)).equals(sol)) : "check3";
		
		testList.clear();
		sol.clear();
		
		//TC4
		
		testList.add(new Defeat1(C,B));
		testList.add(new Defeat1(A,C));
		testList.add(new Tie1(B,D));
		
		sol.add("B");
		sol.add("C");
		sol.add("D");
		
		assert ((A.outranks(testList)).equals(sol)) : "check4";
		
		testList.clear();
		sol.clear();
		
		// TC5
		
		testList.add(new Defeat1(C,E));
		testList.add(new Defeat1(B,C));
		testList.add(new Tie1(B,D));
		testList.add(new Tie1(D,B));
		
		assert ((E.outranks(testList)).isEmpty()) : "check5";
		
		testList.clear();
		sol.clear();
		
		// TC6
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Tie1(A,E));
		
		sol.add("A");
		sol.add("B");
		sol.add("C");
		sol.add("D");
		sol.add("E");
		
		assert (A.outranks(testList)).equals(sol) : "check6";
		
		testList.clear();
		
		// TC7
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Tie1(C,E));
		
		assert (C.outrankedBy(testList)).equals(sol) : "check7";
		
		// TC 8
		
		assert (A.outrankedBy(testList).isEmpty()) : "check8";
		
		// TC9
		
		testList.add(new Defeat1(E,H));
		testList.add(new Defeat1(F,I));
		testList.add(new Defeat1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Defeat1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Defeat1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Defeat1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Defeat1(P,B));
		
		assert (F.outrankedBy(testList).isEmpty()) : "check 9";
		
		sol.add("H");
		sol.add("I");
		sol.add("K");
		sol.add("L");
		sol.add("M");
		sol.add("O");
		sol.add("P");
		
		assert (F.outranks(testList)).equals(sol) : "check10";
		
		// TC11
		
		testList.add(new Tie1(J,P));
		
		sol.add("F");
		sol.add("G");
		sol.add("J");
		sol.add("N");
		
		Collections.sort(sol);
		
		assert (E.outrankedBy(testList)).equals(sol) : "check11";
		
		// TC12
		
		sol.remove("A");
		sol.remove("F");
		sol.remove("G");
		sol.remove("I");
		sol.remove("K");
		sol.remove("M");
		sol.remove("O");
		
		assert (E.outranks(testList)).equals(sol) : "check12";
		
		// TC13
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Tie1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Tie1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Tie1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Tie1(J,P));
		
		sol.add("F");
		sol.add("I");
		
		assert (F.outrankedBy(testList)).equals(sol) : "check13";
		
		// TC14
		
		sol.add("A");
		sol.add("B");
		sol.add("C");
		sol.add("D");
		sol.add("E");
		sol.add("G");
		sol.add("H");
		sol.add("J");
		sol.add("K");
		sol.add("L");
		sol.add("M");
		sol.add("N");
		sol.add("O");
		sol.add("P");
		
		Collections.sort(sol);
		
		assert (F.outranks(testList)).equals(sol) : "check14";
		
		// TC15
		
		sol.remove("A");
		sol.remove("F");
		sol.remove("G");
		sol.remove("I");
		sol.remove("K");
		sol.remove("M");
		sol.remove("O");
		
		assert (E.outranks(testList)).equals(sol) : "check15";
		
		testList.clear();
		
		// TC16
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Tie1(B,C));
		
		assert (A.hasDefeated(B,testList)) : "check16";
		
		// TC 17
		
		testList.clear();
		
		testList.add(new Tie1(A,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Tie1(B,C));
		
		assert (!(A.hasDefeated(C,testList))) : "check17";
		
		// TC1
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,B)); 
		testList.add(new Tie1(A,B));
		testList.add(new Tie1(A,C));
		testList.add(new Defeat1(C,A));
		
		sol.add("C");
		sol.add("A");
		sol.add("B");
		
		assert ((A.powerRanking(testList)).equals(sol)) : "check1";
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Tie1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Defeat1(J,P));
		testList.add(new Tie1(Q,P));
		testList.add(new Defeat1(R,K));
		testList.add(new Tie1(S,L));
		testList.add(new Defeat1(T,A));
		testList.add(new Defeat1(U,B));
		testList.add(new Defeat1(V,E));
		testList.add(new Defeat1(W,P));
		testList.add(new Tie1(X,B));
		testList.add(new Defeat1(Y,E));
		testList.add(new Defeat1(Z,P));
		
		sol.add("T");
		sol.add("U");
		sol.add("W");
		sol.add("Z");
		sol.add("V");
		sol.add("Y");
		sol.add("R");
		sol.add("A");
		sol.add("J");
		sol.add("N");
		sol.add("F");
		sol.add("I");
		sol.add("M");
		sol.add("G");
		sol.add("K");
		sol.add("Q");
		sol.add("X");
		sol.add("B");
		sol.add("P");
		sol.add("C");
		sol.add("E");
		sol.add("D");
		sol.add("H");
		sol.add("S");
		sol.add("L");
		
		assert(A.powerRanking(testList).equals(sol)) : "check2!";
		
		// TC3
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Defeat1(R,K));
		testList.add(new Tie1(S,L));
		testList.add(new Defeat1(T,A));
		testList.add(new Tie1(U,B));
		testList.add(new Tie1(V,E));
		testList.add(new Defeat1(W,P));
		testList.add(new Tie1(X,B));
		testList.add(new Defeat1(Y,E));
		testList.add(new Tie1(Z,P));
		
		sol.add("T");
		sol.add("Y");
		sol.add("W");
		sol.add("R");
		sol.add("A");
		sol.add("K");
		sol.add("F");
		sol.add("I");
		sol.add("L");
		sol.add("S");
		sol.add("Z");
		sol.add("P");
		sol.add("C");
		sol.add("U");
		sol.add("X");
		sol.add("B");
		sol.add("V");
		sol.add("E");
		sol.add("D");
		sol.add("H");
		
		assert(A.powerRanking(testList).equals(sol)) : "check3!";
		
		// TC 4
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Tie1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Tie1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Tie1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Defeat1(J,P));
		testList.add(new Tie1(Q,P));
		testList.add(new Defeat1(R,K));
		testList.add(new Tie1(S,L));
		testList.add(new Defeat1(T,A));
		testList.add(new Tie1(U,B));
		testList.add(new Tie1(V,E));
		testList.add(new Defeat1(W,P));
		testList.add(new Tie1(X,B));
		testList.add(new Defeat1(Y,E));
		testList.add(new Tie1(Z,P));
		
		sol.add("R");
		sol.add("T");
		sol.add("W");
		sol.add("Y");
		sol.add("F");
		sol.add("I");
		sol.add("M");
		sol.add("G");
		sol.add("K");
		sol.add("O");
		sol.add("A");
		sol.add("C");
		sol.add("J");
		sol.add("N");
		sol.add("Q");
		sol.add("S");
		sol.add("U");
		sol.add("V");
		sol.add("X");
		sol.add("Z");
		sol.add("B");
		sol.add("E");
		sol.add("L");
		sol.add("P");
		sol.add("D");
		sol.add("H");
		
		assert(A.powerRanking(testList).equals(sol)) : "check4!";
		
		// TC5
		
		testList.clear();
		sol.clear();
		
		testList.add(new Tie1(B,C));
		testList.add(new Tie1(A,B));
		
		sol.add("A");
		sol.add("B");
		sol.add("C");
		
		assert(A.powerRanking(testList).equals(sol)) : "check5!";
		
		// TC6
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Tie1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Tie1(J,P));
		
		sol.add("A");
		sol.add("F");
		sol.add("I");
		sol.add("M");
		sol.add("K");
		sol.add("O");
		sol.add("C");
		sol.add("D");
		sol.add("E");
		sol.add("J");
		sol.add("N");
		sol.add("P");
		sol.add("B");
		sol.add("H");
		sol.add("L");
		
		assert(A.powerRanking(testList).equals(sol)) : "check6!";
		
		// TC7
		
		testList.clear();
		sol.clear();
		
		testList.add(new Tie1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Tie1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Tie1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Tie1(G,K));
		testList.add(new Tie1(H,L));
		testList.add(new Tie1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Tie1(K,O));
		testList.add(new Tie1(L,P));
		testList.add(new Tie1(M,K));
		testList.add(new Tie1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Tie1(J,P));
		
		sol.add("F");
		sol.add("G");
		sol.add("I");
		sol.add("K");
		sol.add("M");
		sol.add("O");
		sol.add("B");
		sol.add("C");
		sol.add("D");
		sol.add("E");
		sol.add("H");
		sol.add("J");
		sol.add("L");
		sol.add("N");
		sol.add("P");
		sol.add("A");
		
		assert(A.powerRanking(testList).equals(sol)) : "check7!";
		
		// TC8
		
		testList.clear();
		sol.clear();
		
		testList.add(new Tie1(A,E));
		testList.add(new Defeat1(C,B));
		testList.add(new Defeat1(B,A));
		testList.add(new Defeat1(A,C));
		testList.add(new Tie1(B,C));
		
		sol.add("E");
		sol.add("A");
		sol.add("B");
		sol.add("C");
		
		assert(A.powerRanking(testList).equals(sol)) : "check8!";
		
		// TC9
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(C,E));
		testList.add(new Defeat1(D,C));
		testList.add(new Tie1(D,B));
		
		sol.add("B");
		sol.add("D");
		sol.add("C");
		sol.add("E");
		
		assert(A.powerRanking(testList).equals(sol)) : "check9!";
		
		// TC10
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Tie1(C,E));
				
		sol.add("A");
		sol.add("B");
		sol.add("C");
		sol.add("D");
		sol.add("E");
			
		assert(A.powerRanking(testList).equals(sol)) : "check10!";
		
		// TC11
		
		testList.clear();
		sol.clear();
		
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Defeat1(F,I));
		testList.add(new Defeat1(I,M));
		testList.add(new Defeat1(M,K));
		testList.add(new Defeat1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Defeat1(P,B));
		testList.add(new Tie1(C,E));
					
		sol.add("O");
		sol.add("P");
		sol.add("F");
		sol.add("N");
		sol.add("A");
		sol.add("I");
		sol.add("L");
		sol.add("M");
		sol.add("B");
		sol.add("K");
		sol.add("C");
		sol.add("E");
		sol.add("D");
		sol.add("H");
					
		assert(A.powerRanking(testList).equals(sol)) : "check11!";
				
		// TC12
		
		testList.clear();
		sol.clear();
				
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Defeat1(F,I));
		testList.add(new Defeat1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Defeat1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Defeat1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Defeat1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Defeat1(P,B));
		testList.add(new Tie1(C,E));
							
		sol.add("F");
		sol.add("G");
		sol.add("J");
		sol.add("I");
		sol.add("N");
		sol.add("M");
		sol.add("K");
		sol.add("O");
		sol.add("A");
		sol.add("C");
		sol.add("E");
		sol.add("D");
		sol.add("H");
		sol.add("P");
		sol.add("B");
		sol.add("L");
							
		assert(A.powerRanking(testList).equals(sol)) : "check12!";
				
		// TC13
		
		testList.clear();
		sol.clear();
				
		testList.add(new Defeat1(A,B));
		testList.add(new Defeat1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Defeat1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Defeat1(F,I));
		testList.add(new Defeat1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Defeat1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Defeat1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Defeat1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Defeat1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Tie1(J,P));
									
		sol.add("F");
		sol.add("G");
		sol.add("I");
		sol.add("M");
		sol.add("K");
		sol.add("O");
		sol.add("A");
		sol.add("J");
		sol.add("C");
		sol.add("E");
		sol.add("P");
		sol.add("D");
		sol.add("H");
		sol.add("N");
		sol.add("B");
		sol.add("L");
									
		assert(A.powerRanking(testList).equals(sol)) : "check13!";
		
		// TC14
		
		testList.clear();
		sol.clear();
						
		testList.add(new Defeat1(A,D));
		testList.add(new Defeat1(A,E));
		testList.add(new Defeat1(C,B));
		testList.add(new Defeat1(C,F));
		testList.add(new Tie1(D,B));
		testList.add(new Defeat1(F,E));
											
		sol.add("C");
		sol.add("A");
		sol.add("F");
		sol.add("E");
		sol.add("B");
		sol.add("D");
										
		assert(A.powerRanking(testList).equals(sol)) : "check14!";
		
		// TC15

		testList.clear();
		sol.clear();
				
		testList.add(new Defeat1(A,B));
		testList.add(new Tie1(B,C));
		testList.add(new Defeat1(C,D));
		testList.add(new Tie1(D,E));
		testList.add(new Defeat1(E,H));
		testList.add(new Tie1(F,I));
		testList.add(new Tie1(G,K));
		testList.add(new Defeat1(H,L));
		testList.add(new Defeat1(I,M));
		testList.add(new Tie1(J,N));
		testList.add(new Defeat1(K,O));
		testList.add(new Tie1(L,P));
		testList.add(new Defeat1(M,K));
		testList.add(new Tie1(N,L));
		testList.add(new Defeat1(O,A));
		testList.add(new Tie1(P,B));
		testList.add(new Tie1(C,E));
		testList.add(new Tie1(J,P));
									
		sol.add("F");
		sol.add("I");
		sol.add("M");
		sol.add("G");
		sol.add("K");
		sol.add("O");
		sol.add("A");
		sol.add("C");
		sol.add("E");
		sol.add("J");
		sol.add("N");
		sol.add("P");
		sol.add("B");
		sol.add("L");
		sol.add("D");
		sol.add("H");
		
		assert(A.powerRanking(testList).equals(sol)) : "check15!";
		
		System.out.println("All unit tests of set09 passed.");

	}
}
 
//Constructor template for PlayerProfile:
//new PlayerProfile (String c1, int noOutranks, int noOutranked, double perc)
//Interpretation:
//the object of this class represents the overall performance of Competitor
//c1 based on the list of outcomes

class PlayerProfile 
{
	String name = "";    // Name of the Competitor
	int noOutranks = 0;  // No of Competitors the given Competitor outranks
	int noOutranked = 0; // No of Competitors that outrank the given Competitor
	double perc = 0.0;   // Non losing percentage for the given Competitor
	
	// Getters and Setters
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getNoOutranks() {
		return noOutranks;
	}
	public void setNoOutranks(int noOutranks) {
		this.noOutranks = noOutranks;
	}
	public int getNoOutranked() {
		return noOutranked;
	}
	public void setNoOutranked(int noOutranked) {
		this.noOutranked = noOutranked;
	}
	public double getPerc() {
		return perc;
	}
	public void setPerc(double perc) {
		this.perc = perc;
	}
	
}

//Constructor template for PlayerScore:
//new PlayerScore (String c1, int lost, int total)
//Interpretation:
//the object of this class represents the score of Competitor
//c1 based on the outcomes processed till now

class PlayerScore
{
	String name = ""; // Name of the competitor
	int lost = 0;     // Number of lost outcomes for the given Competitor
	int total = 0;    // Number of total outcomes for the given Competitor
	
	// Getters and Setters
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getLost() {
		return lost;
	}
	public void setLost(int lost) {
		this.lost = lost;
	}
	public int getTotal() {
		return total;
	}
	public void setTotal(int total) {
		this.total = total;
	}
	
}