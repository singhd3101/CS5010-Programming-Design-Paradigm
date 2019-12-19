
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

public class TestRosterWithStream {

	public static void main(String[] args) {
		
		Player p1 = Players.make("A");
		Player p3 = Players.make("B");
		Player d = Players.make("D");
		Player e = Players.make("E");
		Player f = Players.make("F");
		
		RosterWithStream r = RosterWithStreams.empty();
		RosterWithStream r1 = RosterWithStreams.empty().with(p3).with(p3);
		RosterWithStream r3 = RosterWithStreams.empty();
		
		r3 = r3.with(d).with(e).with(f);
		
		e.changeInjuryStatus(true);
		f.changeSuspendedStatus(true);
		
		//findFirst()
		//RETURNS: an Optional describing the first element of this stream, 
		//or an empty Optional if the stream is empty
		
		assert(!RosterWithStreams.empty().stream().findFirst().isPresent())
		       : "check49";
		assert(RosterWithStreams.empty().with(p1).stream().findFirst()
				.get().equals(p1)) : "check50";
		assert(!r3.with(p1).stream().findFirst().get().equals(f)) : "check64";
		assert(r3.with(p1).stream().findFirst().get().equals(p1)) : "check65";
		assert(r3.stream().findFirst().get().equals(d)) : "check67";
		
		r1 = r1.with(p1).with(e).with(p3).with(f);
		
		//distinct()
		//RETURNS: Returns a stream consisting of the distinct elements of 
		//this stream.		
		
	    assert(r1.stream().distinct().collect(Collectors.toList()).
	    		equals(r1.stream().collect(Collectors.toList()))) : "check54";
		
	    //count()
	    //RETURNS:  the count of elements in this stream.
	    
	    assert(r1.stream().filter((Player p) -> p.available()).
	    		count()==r1.readyCount()) : "check52";
	    assert(r1.stream().count()==4) : "check53";
		assert(r.stream().count()==0) : "check55";
		assert(RosterWithStreams.empty().stream().count()==0) : "check48";
		
		//filter
		//RETURNS: Returns a stream consisting of the elements of this stream
		//that match the given predicate.
		
		assert(r1.stream().filter((Player p) -> p.name().contains("E")).
				count()==1) : "check61";
		assert(r.stream().filter((Player p) -> p.isInjured()).
				count()==0) : "check62";
		assert(r1.stream().filter((Player p) -> p.isInjured()).
				count()==1) : "check82";
		
		Player p11 = Players.make("P11");
		Player p12 = Players.make("P12");
		Player p13 = Players.make("P13");
		Player p14 = Players.make("P14");
		Player p15 = Players.make("P15");
		
		//allMatch(Predicate<? super T> predicate) 
		//RETUNRS: true if either all elements of the stream match the provided
		//predicate or the stream is empty, otherwise false
		
		RosterWithStream r5 = RosterWithStreams.empty().with(p11).with(p12).
				with(p13).with(p14).with(p15);
		
		assert(r5.stream().allMatch(p -> p.name().startsWith("P"))) :"check56";
		assert(!r5.stream().allMatch(p -> p.name().startsWith("Q"))):"check57";
		
		r5 = r5.with(e);
		assert(!r5.stream().allMatch(p -> p.name().startsWith("P"))):"check58";
		
		//anyMatch(Predicate<? super T> predicate)
		
		assert(r5.stream().anyMatch(p -> p.name().startsWith("E"))):"check59";
		assert(!r5.stream().anyMatch(p -> p.name().startsWith("Q")))
		: "check60";
		
		//findAny()
		//RETUNRS: true if any elements of the stream match the provided 
		//predicate, otherwise false
		
		Optional<Player> op = r.stream().findAny();
		
		assert (!op.isPresent()) : "check61";
		
		op = r5.stream().findAny();
		
		assert(op.get().equals(p15) || op.get().equals(e)) : "check62";
		assert(!op.get().equals(p15)) : "check63";
		
		//forEach(Consumer<? super T> action)
		//RETURNS: Performs an action for each element of this stream.
		
		r5.stream().forEach(p -> p.changeSuspendedStatus(true));
		
		assert(r5.readyCount()==0) : "check68";
		
		r5.stream().forEach(p -> p.changeSuspendedStatus(false));
		
		assert(r5.readyCount()==5) : "check69";
		
		//map(Function<? super T,? extends R> mapper)
		//RETURNS: Returns a stream consisting of the results of applying the 
		//given function to the elements of this stream.
		
		List<String> lp = Arrays.asList("E","P11","P12","P13","P14","P15");
		
		assert(r5.stream().map(p -> p.name()).collect(Collectors.toList()).
				containsAll(lp)) : "check70";
		assert(!r5.stream().map(p -> p.name()).collect(Collectors.toList()).
				contains("J")) : "check71";
		assert(r.stream().map(p -> p.name()).collect(Collectors.toList()).
				containsAll(new ArrayList<String>())) : "check72";
		
		//reduce(T identity, BinaryOperator<T> accumulator)
		//RETURNS: Performs a reduction on the elements of this stream, using
		//the provided identity value and an associative accumulation function,
		//and returns the reduced value. 
		
		String res = "EP11P12P13P14P15";
		
		assert(r5.stream().map(p -> p.name()).
				reduce("", (s1,s2) -> s1+s2).equals(res)) : "check79";
		assert(r5.stream().reduce((x,y) -> x.name().contains(y.name()) ? x : y).
				get().equals(p15)) : "check80";
		
		//skip(long n)
		//RETURNS: a stream consisting of the remaining elements of this stream 
		//after discarding the first n elements of the stream.
		
		assert(RosterWithStreams.empty().stream().skip(4).
				collect(Collectors.toList()).size()==0) : "Check73";
		assert(r5.stream().skip(4).collect(Collectors.toList()).size()==2) : 
			"Check74";
		assert(r5.without(e).stream().skip(4).
				collect(Collectors.toList()).size()==1) : "Check75";
		
		//toArray()
		//RETURNS: an array containing the elements of this stream.
		
		assert(r5.stream().toArray().length==6) : "check76";
		assert(r5.stream().toArray() instanceof Object[]) : "check77";
		assert(r.stream().toArray().length==0) : "check78";
		
		Object[] ar = r5.stream().toArray();
		RosterWithStream newRoster = RosterWithStreams.empty();
		
		for(Object t: ar)
		{
			Player tt = (Player)t;
			newRoster = newRoster.with(tt);
		}
		
		assert(r5.equals(newRoster)) : "check81";
		
		String[] arg = {};
		PdpQ1Tests.main(arg);
		PdpQ2Tests.main(arg);
		Tests.main(arg);
		
		System.out.println("All test cases passed for set11");

	}

}
