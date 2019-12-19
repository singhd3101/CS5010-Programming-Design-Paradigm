
public class Tests {

	public static void main(String[] args) {

RosterWithStream r = RosterWithStreams.empty();
		
		assert (RosterWithStreams.empty().size()==0) : "check1";
				
		Player p1 = Players.make("A");
		Player p2 = p1;
		Player p3 = Players.make("B");
		
		assert (p1.available()) : "check2";
		assert (p1.name()=="A") : "check3";
		assert (p1.underContract()) : "check4";
		assert (!p1.isInjured()) : "check5";
		assert (!p1.isSuspended()) : "check6";
		
		p1.changeContractStatus(false);
		assert (!p1.underContract()) : "check7";
		
		p1.changeInjuryStatus(true);
		assert (p1.isInjured()) : "check8";
		
		p1.changeSuspendedStatus(true);
		assert (p1.isSuspended()) : "check9";
		
		assert(Players.make("Gordon Wayhard").name()=="Gordon Wayhard") : "check10" ;
		
		Player gw = Players.make ("Gordon Wayhard");
		
		assert (gw.available()) : "check11";
		
		gw.changeInjuryStatus (true);
		
		assert (!gw.available()) : "check12";
		
		Player ih = Players.make ("Isaac Homas");
		
		assert (ih.underContract()) : "check13";
		
		ih.changeContractStatus (false);
		
		assert (!ih.underContract()) : "check14";
		
		ih.changeContractStatus (true);
		
		assert (ih.underContract()) : "check15";
		
		assert (p1.equals(p2)) : "check16";
		assert (!p3.equals(p2)) : "check17";
		
		assert (p1.hashCode()==p2.hashCode()) : "check18";
		assert (!(p1.hashCode()==p3.hashCode())) : "check19";
		
		assert (p1.toString().equals(p2.toString())) : "check20";
		assert (!(p1.toString().equals(p3.toString()))) : "check21";
		
		RosterWithStream r1 = r.with(p3).with(p3);
		RosterWithStream r2 = r.with(p3);
		
		assert (r1.equals(r2)) : "check22";
		assert (!r.equals(r2)) : "check23";
		assert (!RosterWithStreams.empty().equals(r2)) : "check24";
		
		assert (RosterWithStreams.empty().without(p1).equals(RosterWithStreams.empty())) : "check25";
		assert (r1.without(p1).without(p1).equals(r1.without(p1))) : "check26";
		
		assert (!RosterWithStreams.empty().has(p1)) : "check27";
		assert (RosterWithStreams.empty().with(p3).has(p3)) : "check28";
		assert (!RosterWithStreams.empty().without(p3).has(p3)) : "check29";
		
		assert (RosterWithStreams.empty().size()==0) : "check30";
		assert (r1.size()==1) : "check31";
		
		assert (r1.without(p1).size()==1) : "check32";
		assert (r1.without(p3).size()==0) : "check33";
		
		assert (r1.with(p1).size()==2) : "check34";
		assert (r1.with(p1).with(p1).size()==2) : "check35";
		assert (r1.with(p1).without(p1).size()==1) : "check36";
		
		Player d = Players.make("D");
		Player e = Players.make("E");
		Player f = Players.make("F");
		
		int h1 = e.hashCode();
		
		RosterWithStream r3 = RosterWithStreams.empty();
     	RosterWithStream r4 = RosterWithStreams.empty();
	
		assert(r3.equals(r4)) : "check47";
		
		assert (r3.readyCount()==0) : "check37";
		assert (r3.with(d).with(e).with(f).readyCount()==3) : "check38";
		assert (r3.with(d).with(e).with(f).readyRoster().equals(r4.with(d).with(e).with(f))) : "check39";
	
		r3 = r3.with(d).with(e).with(f);
		
		assert (r3.readyCount()==3) : "check43";
		
		e.changeInjuryStatus(true);
		f.changeSuspendedStatus(true);
		r4.without(e).without(f);
		
		assert (h1==e.hashCode()) : "check42";
		
		assert (r3.with(d).with(e).with(f).readyCount()==1) : "check40";
		assert (r3.readyCount()==1) : "check47";
		assert (r3.with(d).with(e).with(f).readyRoster().equals(r4.with(d).with(e).with(f).readyRoster())) : "check41";
		
		assert (RosterWithStreams.empty().readyRoster().equals(RosterWithStreams.empty())) : "check44";
		
		assert(!r1.equals(p3)) : "check45";
		assert(!r1.has(p1)) : "check46";

	}

}
