import java.io.*;
import java.util.*;
import java.util.function.*;

/**
 * Tests for Problem Set 11, question 2.
 *
 * We use a Scheme program in a preprocessing step to count the number of
 * times the student's tests call certain stream methods.  This class then
 * loads the counts from a text file.  We are checking only for minimal
 * test coverage.  Additional tests are a good idea, but it's difficult to
 * come up with precise numbers.
 *
 * Three points are given for a test program that runs without crashing or
 * throwing an exception.  In order to use pre-existing infrastructure in
 * which each test is worth one point, this class splits this property into
 * three "tests," which will all succeed or fail together.
 */
public class PdpQ2Tests {
    public static void main(String[] args) {
        PdpTestSuite tests = new PdpTestSuite(60);

        Map<String, Integer> methodCalls = new HashMap<>();

        String fname = "test_counts.txt";
        try (BufferedReader br = new BufferedReader(new FileReader(fname))) {
            br.lines().forEach(line -> {
                if (!line.trim().equals("")) {
                    String[] fields = line.split(" ");
                    methodCalls.put(fields[1], Integer.parseInt(fields[0]));
                }
            });
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }

        /* We expect at least one call to each of these methods, and at
         * least two calls to each of the methods in the list below. */
        List<String> methods = Arrays.asList(
                "allMatch", "anyMatch", "count", "distinct", "filter",
                "findAny", "findFirst", "forEach", "map", "reduce", "skip",
                "toArray"
        );
        List<String> twoTestMethods = Arrays.asList(
                "allMatch", "anyMatch", "findAny", "findFirst"
        );

        methods.forEach(m -> {
            tests.addTestCase("enough calls to " + m, () -> {
                if (!methodCalls.containsKey(m)) {
                    return false;
                } else if (twoTestMethods.contains(m)) {
                    return methodCalls.get(m) >= 2;
                } else {
                    return methodCalls.get(m) >= 1;
                }
            }, true);
        });

        /* The call to the student's main method happens outside of a
         * test case, so we have to take care to catch any exceptions. */
        boolean mainSucceeded = false;
        try {
            TestRosterWithStream.main(new String[] {});
            mainSucceeded = true;
        } catch (Exception e) {
            // nothing to do
        }

        final boolean pass = mainSucceeded;
        tests.addTestCase("main runs without errors 1/3", () -> pass, true);
        tests.addTestCase("main runs without errors 2/3", () -> pass, true);
        tests.addTestCase("main runs without errors 3/3", () -> pass, true);

        tests.runTests();
    }
}
