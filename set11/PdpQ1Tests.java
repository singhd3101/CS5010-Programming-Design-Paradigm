import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Supplier;

/**
 * Tests for Problem Set 11, Question 1.
 */
public class PdpQ1Tests {

    /**
     * for testing forEach
      */
    private static int counter = 0;

    /**
     * List of Players
     */
    static Player p1;
    static Player p5;
    static Player p6;
    static Player p7;
    static Player p8;
    static Player p9;
    static Player p10;

    static void initPlayers() {
        p1 = Players.make("Player1");
        p5 = Players.make("Player5");
        p6 = Players.make("Player6");
        p7 = Players.make("Player7");
        p8 = Players.make("Player8");
        p9 = Players.make("Player9");
        p10 = Players.make("Player10");
    }

    /** Wraps the given actual thunk with initialization. */
    static <T> void addCase(PdpTestSuite tests, String name,
                            Supplier<T> actualFn, T expected) {
        Supplier<T> a2 = () -> {
            initPlayers();
            counter =0;
            return actualFn.get();
        };
        tests.addTestCase(name, a2, expected);
    }

    static RosterWithStream rosterWithStream(Player... ps) {
        RosterWithStream r = RosterWithStreams.empty();
        for (Player p : ps) {
            r = r.with(p);
        }
        return r;
    }

    static <T> boolean giveEqualElements(Iterable<T> a, Iterable<T> b) {
        Iterator<T> it1 = a.iterator();
        Iterator<T> it2 = b.iterator();
        while (it1.hasNext() && it2.hasNext()) {
            if (!it1.next().equals(it2.next())) {
                return false;
            }
        }
        return it1.hasNext() == it2.hasNext();
    }

    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(15);

        addCase(tests, "empty rosters with streams are equal", () -> {
            return RosterWithStreams.empty().equals(RosterWithStreams.empty());
        }, true);

        addCase(tests, "empty rosters with streams does not equal null", () -> {
            return RosterWithStreams.empty().equals(null);
        }, false);

        addCase(tests, "nonempty rosters with streams does not equal null", () -> {
            return rosterWithStream(p10).equals(null);
        }, false);

        addCase(tests, "empty rosters with streams does not equal System.class", () -> {
            return RosterWithStreams.empty().equals(System.class);
        }, false);

        addCase(tests, "nonempty rosters with streams does not equal System.class", () -> {
            return rosterWithStream(p10).equals(System.class);
        }, false);

        addCase(tests, "equals, same order, immutability", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p9, p10);
            RosterWithStream r3 = rosterWithStream(p6, p7, p8, p9, p10);
            r3.with(p1); // no effect
            return r3.equals(r2);
        }, true);

        addCase(tests, "equals, different order", () -> {
            RosterWithStream r2 = rosterWithStream(p9, p6, p8, p10, p7);
            RosterWithStream r3 = rosterWithStream(p6, p7, p8, p9, p10);
            return r3.equals(r2);
        }, true);

        addCase(tests, "unequal rosters with stream", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p9, p10);
            RosterWithStream r3 = rosterWithStream(p6, p7, p5, p8, p9, p10);
            return r3.equals(r2) || r2.equals(r3);
        }, false);

        addCase(tests, "unequal rosters with stream, one empty", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p9, p10);
            RosterWithStream r3 = rosterWithStream();
            return r3.equals(r2) || r2.equals(r3);
        }, false);

        addCase(tests, "readyCount with redundant addition", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p5, p9, p8);
            return r2.readyCount();
        }, 5);

        addCase(tests, "hashCode, immutability", () -> {
            RosterWithStream r = rosterWithStream(p1);
            int c = r.hashCode();
            r.with(p10).without(p1).with(p5);  // no effect
            return r.hashCode() == c;
        }, true);

        addCase(tests, "toString(), two nonempty", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p9, p10);
            RosterWithStream r3 = rosterWithStream(p6, p7, p8, p9, p10, p5);
            return r2.toString().equals(r3.toString());
        }, false);

        addCase(tests, "set size, immutability", () -> {
            RosterWithStream r2 = rosterWithStream(p6, p7, p8, p8, p7);
            r2.with(p9);  // no effect
            r2.with(p10); // no effect
            return r2.size();
        }, 3);

        addCase(tests, "has()", () -> {
            RosterWithStream r3 = rosterWithStream(p6, p7, p8, p8)
                    .without(p7).with(p7)
                    .without(p9).with(p9)
                    .with(p10)
                    .with(p5).without(p5);
            return (!r3.has(p5) && r3.has(p9) && r3.has(p7) && r3.has(p9));
        }, true);

        addCase(tests, "iterator over multiple players", () -> {
            Player p11 = Players.make("AAA");
            Player p12 = Players.make("ABA");
            Player p13 = Players.make("BAB");
            Player p14 = Players.make("AAB");
            Player p15 = Players.make("BAA");
            RosterWithStream r1 = rosterWithStream(p11, p12, p13, p14, p15);
            List<Player> expected = Arrays.asList(p11, p14, p12, p15, p13);
            return giveEqualElements(r1, expected);
        }, true);

        addCase(tests, "iterator with same name", () -> {
            Player p11 = Players.make("AAA");
            Player p12 = Players.make("ABA");
            Player p13 = Players.make("AAA");
            Player p14 = Players.make("AAB");
            Player p15 = Players.make("BAA");
            RosterWithStream r1 = rosterWithStream(p11, p12, p13, p14, p15);
            List<Player> expected1 = Arrays.asList(p11, p13, p14, p12, p15);
            List<Player> expected2 = Arrays.asList(p13, p11, p14, p12, p15);
            return giveEqualElements(r1, expected1)
                    || giveEqualElements(r1, expected2);
        }, true);

        addCase(tests, "iterator and size for empty", () -> {
            RosterWithStream r0 = RosterWithStreams.empty();
            Iterator<Player> it = r0.iterator();
            return r0.size() == 0 && !it.hasNext();
        }, true);

        addCase(tests, "iterator, immutability", () -> {
            RosterWithStream r = rosterWithStream(p8, p5, p6);
            r.with(p7).without(p5);  // no effect
            return giveEqualElements(r, Arrays.asList(p5, p6, p8));
        }, true);

        // testing stream

        addCase(tests, "allMatch should be true for p.available()", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5, p6, p8);
            return r1.stream().allMatch ((Player p) -> p.available());
        }, true);

        addCase(tests, "allMatch should be false for p.available()", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5, p6, p8);
            p1.changeSuspendedStatus(true);
            return r1.stream().allMatch ((Player p) -> p.available());
        }, false);

        addCase(tests, "anyMatch should be false for p.isInjured()", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5, p6, p8);
            return r1.stream().anyMatch ((Player p) -> p.isInjured());
        }, false);

        addCase(tests, "anyMatch should be true for !p.available()", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5, p6, p8);
            p1.changeSuspendedStatus(true);
            return r1.stream().anyMatch ((Player p) -> !p.available());
        }, true);

        addCase(tests, "count should be zero for an empty roster", () -> {
            RosterWithStream r0 = RosterWithStreams.empty();
            return r0.stream().count() == 0;
        }, true);

        addCase(tests, "count should be four for the given roster", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p1,p5,p6,p8);
            return r1.stream().count() == 4;
        }, true);

        addCase(tests, "distinct count should be four for the given roster", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5,p6,p5,p6,p8);
            return r1.stream().count() == r1.stream().distinct().count();
        }, true);

        addCase(tests, "filter should filter out for the given roster", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9);
            p1.changeSuspendedStatus(true);
            p9.changeInjuryStatus(true);
            return r1.stream().filter ((Player p) -> p.isInjured() || p.isSuspended()).count()==2;
        }, true);

        addCase(tests, "find any should return one of the two filter output", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9);
            p1.changeSuspendedStatus(true);
            p9.changeInjuryStatus(true);
            RosterWithStream r2 = rosterWithStream(p1,p9);
            Player player = r1.stream().filter ((Player p) -> p.isInjured() || p.isSuspended()).findAny().get();
            return r2.stream().anyMatch((Player pl) -> pl.equals(player));
        }, true);

        addCase(tests, "find first should return players in alphabetical order by name", () -> {
            Player p11 = Players.make("AAA");
            Player p12 = Players.make("ABA");
            Player p13 = Players.make("AAC");
            Player p14 = Players.make("AAB");
            Player p15 = Players.make("BAA");
            RosterWithStream r1 = rosterWithStream(p13,p15,p14,p11,p12,p13);
            return r1.stream().findFirst().get().name().equals("AAA");
        }, true);

        addCase(tests, "foreach iterates through out the roster stream", () -> {
            RosterWithStream r1 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9);
            p9.changeContractStatus(false);
            r1.stream().forEach(new Consumer<Player>() {
                @Override
                public void accept (Player p) {
                    if (p.available())
                        counter = counter + 1;
                }});
            return counter==4;
        }, true);

        addCase(tests, "counter should return zero for an empty roster", () -> {
            RosterWithStream r1 = RosterWithStreams.empty();
            r1.stream().forEach(new Consumer<Player>() {
                @Override
                public void accept (Player p) {
                    if (p.available())
                        counter = counter + 1;
                }});
            return counter==0;
        }, true);

        addCase(tests, "map should return an empty stream when given empty stream", () -> {
            RosterWithStream r0 = RosterWithStreams.empty();
            return r0.stream().map ((p) -> p).count() == 0;
        }, true);

        addCase(tests, "map should return player who is not under contract", () -> {
            RosterWithStream r0 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9);
            p9.changeContractStatus(false);
            return r0.stream().filter((Player p) -> !p.underContract())
                    .map ((p) -> p.name()).findAny().get()
                    .equals ("Player9");
        }, true);

        addCase(tests, "reduce should return names for r0 players", () -> {
            RosterWithStream r0 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9);
            StringBuilder sb = new StringBuilder();
            for (Player p : r0)
                sb.append (p.name());
            return r0.stream().map((p) -> p.name())
                    .reduce ("", (s1,s2) -> (s1 + s2)).equals (sb.toString());
        }, true);

        addCase(tests, "skipping items of empty stream should work", () -> {
            RosterWithStream r0 = RosterWithStreams.empty();
            return r0.stream().skip(25).count() == 0;
        }, true);

        addCase(tests, "skipping items of stream should return the remaining stream", () -> {
            RosterWithStream r0 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9,p7,p10);
            return r0.stream().skip(2).count() == 5;
        }, true);

        addCase(tests, "check for toArray() and skip()", () -> {
            RosterWithStream r0 = rosterWithStream(p1,p5,p6,p5,p6,p8,p9,p7,p10);
            return r0.stream().skip(2).toArray().length == 5;
        }, true);

        tests.runTests();
    }
}
