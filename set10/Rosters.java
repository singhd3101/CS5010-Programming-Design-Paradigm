//Constructor template for Players:
//Rosters() - represents an empty Roster
//Rosters(lst) - represents an Roster with a lst list of Players
//Static Factory method empty() uses the first Constructor to return a
//Rosters object
//Interpretation: represents a set of Players

import java.util.*;
import java.util.stream.Collectors;

public class Rosters implements Roster
{
	private List<Player> lst; // represents the list of Players in a Roster
	
	private Rosters()
	{
		lst = new ArrayList<Player>();
	}
	
	private Rosters(List<Player> plist)
	{
		lst = new ArrayList<Player>(plist);
	}
	
	//GIVEN: no argument
	//RETUNRS: static factory method that returns an
    // empty roster.
	//EXAMPLE: Rosters.empty().size() = 0 
	
	public static Roster empty()
	{
		Roster r = new Rosters();
		
		return r;
	}

	//GIVEN: a Player
	//RETUNRS: a roster consisting of the given player together
    // with all players on this roster.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: r.with(p).with(p)  =>  r.with(p)
	
	public Roster with(Player p) 
	{
		Iterator<Player> itr = iterator();
		
		Boolean flag = false;
			
		while (itr.hasNext())
		{
			Player pl = itr.next();
			
			if (pl.equals(p))
			{
				flag = true;
			}			
		}
		
		List<Player> lstnew = new ArrayList<Player>(lst);
		
		if (!flag)
		{
			lstnew.add(p);
		}
		
		Roster r = new Rosters(lstnew);
		
		return r;
	}

	//GIVEN: a Player
	//RETUNRS: a roster consisting of all players on this roster
    // except for the given player.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE:  r.without(p).without(p)     =>  r.without(p)
	
	public Roster without(Player p) 
	{
		Iterator<Player> itr = iterator();
		
		Boolean flag = false;
		
		while (itr.hasNext())
		{
			Player pl = itr.next();
			
			if (pl.equals(p))
			{
				flag = true;
			}			
		}
		
		List<Player> lstnew = new ArrayList<Player>(lst);
		
		if (flag)
		{
			lstnew.remove(p);
		}
		
		Roster r = new Rosters(lstnew);
		
		return r;
		
	}

	//GIVEN: a Player
	//RETUNRS: true iff the given player is on this roster.
	//EXAMPLE:  Rosters.empty().has(p)  =>  false
	//HALTING MEASURE: Number of elements in itr
	//  If r is any roster, then r.with(p).has(p)     =>  true
	
	public boolean has(Player p) 
	{
		Iterator<Player> itr = iterator();
		
		Boolean flag = false;
		
		while (itr.hasNext())
		{
			Player pl = itr.next();
			
			if (pl.equals(p))
			{
				flag = true;
			}			
		}
		
		return flag;
	}

	//GIVEN: no argument
	//RETUNRS: the number of players on this roster.
	//EXAMPLE:  Rosters.empty().size()  =>  0
    // If r is a roster with r.size() == n, and r.has(p) is false, then
    //     r.without(p).size()          =>  n
    //     r.with(p).size()             =>  n+1
    //     r.with(p).with(p).size()     =>  n+1
    //     r.with(p).without(p).size()  =>  n
	
	public int size()
	{
		return lst.size();
	}
	
	//GIVEN: no argument
	//RETUNRS: the number of players on this roster whose current
	// status indicates they are available.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: Rosters.empty().readyCount()  =>  0
	// If r is a roster with player p, p.available() = true, then 
	//    r.readyCount() => 1

	public int readyCount() 
	{
		Iterator<Player> itr = iterator();
		
		int count = 0;
		
		while (itr.hasNext())
		{
			Player pl = itr.next();
			
			if (pl.available())
			{
				count++;
			}			
		}
		
		return count;
	}
	
	//GIVEN: no argument
	//RETUNRS: a roster consisting of all players on this roster
    // whose current status indicates they are available.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: Rosters.empty().readyRoster()  =>  Rosters.empty()
	// If r is a roster with player p,q , p.available() = true, 
	// q.available() = false, then r.readyRoster() => 
	// Rosters.empty().with(p)

	public Roster readyRoster() 
	{
		Iterator<Player> itr = iterator();
		
		List<Player> newlst = new ArrayList<Player>();
		
		while (itr.hasNext())
		{
			Player pl = itr.next();
			
			if (pl.available())
			{
				newlst.add(pl);
			}			
		}
		
		Roster rst = new Rosters(newlst);
		
		return rst;
	}

	//GIVEN: no argument
	//RETUNRS: an iterator that generates each player on this
    // roster exactly once, in alphabetical order by name.
	//EXAMPLE: Rosters.empty().iterator() => empty iterator
	
	@Override
	public Iterator<Player> iterator() 
	{
		List<Player> newlst = new ArrayList<Player>(lst);
		
		newlst = uniqueList(sortByName(newlst));
		
		Iterator<Player> itr = newlst.iterator();	
				
		return itr;
	}
	
	//GIVEN: a list of Players
	//RETUNRS: the input list in alphabetical sorted order by
	// player names.
	//EXAMPLE: If A and B are two players with same attributes
	// except names "A" and "B" respectively, then
	// sortByName([B A]) => [A B]

	private List<Player> sortByName(List<Player> lst)
	{
		lst.sort((p1,p2) ->
		{
			if (checkNameCond (p1, p2))
			{
				return 1;
			}
			else
			{
				return -1;
			}
		});
		
		return lst;
	}
	
	//GIVEN: a list of Players
	//RETUNRS: Player list after removing duplicates
	//EXAMPLE: uniqueList([B A B]) => [B A]
	
	private List<Player> uniqueList(List<Player> lst)
	{
		return lst.stream().distinct().collect(Collectors.toList());
	}
	
	// GIVEN: two Players
	// RETURNS: true iff name of Competitors occur in alphabetical
	//          order in Player objects
	// EXAMPLE: checkNameCond([A B]) => true
	
	private Boolean checkNameCond(Player p1, Player p2)
	{
		if (p1.name().compareTo(p2.name()) < 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	// GIVEN: an Object
	// RETURNS: true iff if and only if every player on roster r1 
	//  is also on roster r2, and every player on roster r2 is
	//  also on roster r1.
	//HALTING MEASURE: Number of elements in iterator
	// EXAMPLE: r.equals(r) => true
	
	@Override
	public boolean equals(Object o)
	{
		if (o instanceof Roster)
		{
			Roster r1 = (Roster)o;
			
			List<Player> lst1 = new ArrayList<Player>(lst);
			List<Player> lst2 = new ArrayList<Player>();
			
			Iterator<Player> i = r1.iterator();

			while(i.hasNext())
			{
				lst2.add(i.next());
			}
			
			if (lst1.equals(lst2))
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
}
