//Constructor template for RosterWithStream1:
//RosterWithStream1() - represents an empty RosterWithStream
//RosterWithStream1(lst) - represents an RosterWithStream with a lst of Players
//Static Factory method empty() uses the first Constructor to return a
//RosterWithStream1 object
//Interpretation: represents a set of Players

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Stream;

public class RosterWithStream1 implements RosterWithStream
{
	
	private List<Player> lst; // represents the list of Players in a RosterWithStream
	
	public RosterWithStream1() 	{
		lst = new ArrayList<Player>();
	}
	
	private RosterWithStream1(List<Player> plist) 	{
		lst = new ArrayList<Player>(plist);
	}

	//GIVEN: a Player
	//RETUNRS: a roster consisting of the given player together
    // with all players on this roster.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: r.with(p).with(p)  =>  r.with(p)
	
	public RosterWithStream with(Player p) {
		List<Player> lstnew = new ArrayList<Player>(lst);
		
		if(!lstnew.contains(p)) {
			lstnew.add(p);
		}
	
		return new RosterWithStream1(lstnew);
	}
	
	//GIVEN: a Player
	//RETUNRS: a roster consisting of all players on this roster
    // except for the given player.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE:  r.without(p).without(p)     =>  r.without(p)

	public RosterWithStream without(Player p)	{		
		List<Player> lstnew = new ArrayList<Player>(lst);
		
		if(lstnew.contains(p)) {
			lstnew.remove(p);
		}
		
		return new RosterWithStream1(lstnew);
		
	}
	
	//GIVEN: a Player
	//RETUNRS: true iff the given player is on this roster.
	//EXAMPLE:  Rosters.empty().has(p)  =>  false
	//HALTING MEASURE: Number of elements in itr
	//  If r is any Roster, then r.with(p).has(p)     =>  true

	public boolean has(Player p) {
		if (lst.contains(p)) {
			return true;
		}
		else {
			return false;
		}
		
	}
	
	//GIVEN: no argument
	//RETUNRS: the number of players on this Roster.
	//EXAMPLE:  Rosters.empty().size()  =>  0
    // If r is a Roster with r.size() == n, and r.has(p) is false, then
    //     r.without(p).size()          =>  n
    //     r.with(p).size()             =>  n+1
    //     r.with(p).with(p).size()     =>  n+1
    //     r.with(p).without(p).size()  =>  n

	public int size() {
		return lst.size();
	}
	
	//GIVEN: no argument
	//RETUNRS: the number of players on this Roster whose current
	// status indicates they are available.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: Rosters.empty().readyCount()  =>  0
	// If r is a Roster with player p, p.available() = true, then 
	//    r.readyCount() => 1

	public int readyCount() {		
		int count = 0;
		
		for(Player p: lst)
		{
			if (p.available())
			{
				count++;
			}
		}
		
		return count;
	}
	
	//GIVEN: no argument
	//RETUNRS: a Roster consisting of all players on this Roster
    // whose current status indicates they are available.
	//HALTING MEASURE: Number of elements in itr
	//EXAMPLE: Rosters.empty().readyRoster()  =>  Rosters.empty()
	// If r is a Roster with player p,q , p.available() = true, 
	// q.available() = false, then r.readyRoster() => 
	// Rosters.empty().with(p)

	public RosterWithStream readyRoster() {
		
		List<Player> newlst = new ArrayList<Player>();
		
		for(Player p: lst)
		{
			if (p.available())
			{
				newlst.add(p);
			}
		}
		
		return new RosterWithStream1(newlst);
		
	}
	
	//GIVEN: no argument
	//RETUNRS: an iterator that generates each player on this
    // Roster exactly once, in alphabetical order by name.
	//EXAMPLE: Rosters.empty().iterator() => empty iterator

	@Override
	public Iterator<Player> iterator() 	{
		List<Player> newlst = new ArrayList<Player>(lst);
		
		newlst = sortByName(newlst);
		
		Iterator<Player> itr = newlst.iterator();	
				
		return itr;
	}
	
	// GIVEN: no argument
	// RETURNS: a sequential Stream with this RosterWithStream
    // as its source.
    // The result of this method generates each player on this
    // roster exactly once, in alphabetical order by name.
    // Examples:
    //
    //     RosterWithStreams.empty().stream().count()  =>  0
    //
    //     RosterWithStreams.empty().stream().findFirst().isPresent()
    //         =>  false
    //
    //     RosterWithStreams.empty().with(p).stream().findFirst().get()
    //         =>  p
    //
    //     this.stream().distinct()  =>  this.stream()
    //
    //     this.stream().filter((Player p) -> p.available()).count()
    //         =>  this.readyCount()
	
	@Override
	public Stream<Player> stream() 	{
		return sortByName(lst).stream();
	}
	
	//GIVEN: a list of Players
	//RETUNRS: the input list in alphabetical sorted order by
	// player names.
	//EXAMPLE: If A and B are two players with same attributes
	// except names "A" and "B" respectively, then
	// sortByName([B A]) => [A B]
	
	private List<Player> sortByName(List<Player> lst)	{
		lst.sort((px, py) -> px.name().compareTo(py.name()));
		return lst;
	}
	
	//GIVEN: No argument
	//RETURNS: If r is a roster, then r.hashCode() always returns the same
    // value, even if r has some players whose status changes.
	//EXAMPLE: RosterWithStreams.empty().hashcode() = 0
	// r5.hashcode() = -1555443805
	
	@Override
	public int hashCode() {
		int hash = 0;
		
		for(Player p: lst) {
			hash = hash + p.hashCode();
		}
		
		return hash;
	}
	
	// GIVEN: an Object
	// RETURNS: true iff if and only if every player on Roster r1 
	//  is also on Roster r2, and every player on Roster r2 is
	//  also on Roster r1.
	//HALTING MEASURE: Number of elements in iterator
	// EXAMPLE: r.equals(r) => true
	
	@Override
	public boolean equals(Object o)	{
		if (o instanceof RosterWithStream)	{
			RosterWithStream r1 = (RosterWithStream)o;
			
			List<Player> lst1 = new ArrayList<Player>(lst);
			List<Player> lst2 = new ArrayList<Player>();
			
			Iterator<Player> i = r1.iterator();

			while(i.hasNext()) {
				lst2.add(i.next());
			}
			
			if(lst1.containsAll(lst2) && lst2.containsAll(lst1)) {
				return true;
			}
			else {
				return false;
			}
			
		}
		else {
			return false;
		}
	}
	
	//GIVEN: No Argument
	//RETURNS: If r1 and r2 are rosters of different sizes, then
    // r1.toString() is not the same string as r2.toString().
	//EXAMPLE: if r1, r2 are two empty rosters, then
	// r1.toString().equals(r2.toString()) => True
	// and r3 a roster with player p, then
	// r1.toString().equals(r3.toString()) => False
	
	@Override
	public String toString() {
		return Integer.toString(size());
	}
}
