package com.gigaspaces.demo.feeder;

import org.openspaces.core.GigaSpace;
import org.openspaces.core.GigaSpaceConfigurer;
import org.openspaces.core.space.SpaceProxyConfigurer;

import java.util.Random;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.logging.Logger;

public class MultithreadedFeeder {

    private static final int MAX_NUM_THREADS = 8;
    private static final int MAX_WRITE_COUNT = 1_000_000;
    private static final int MAX_READ_COUNT = 1_000_000;
    private static final int MAX_RATE_INTERVAL = 60;
    private static final int MAX_NUM_OBJECTS = 10_000_000;
    private static final int MAX_PAYLOAD_SIZE = 20_000;
    private static final int MAX_LEASE_TIMEOUT = 12 * 3600 * 1000;
    private static final int MAX_TIMEOUT = 12 * 3600;
    private static final int MAX_NUMBER_OF_SITES = 3;

    private static Logger log = Logger.getLogger(MultithreadedFeeder.class.getName());
    private GigaSpace gigaSpace;

    private static final String DEFAULT_SPACE_NAME = "mySpace";

    // default number of threads
    private static final int DEFAULT_NUM_THREADS = 5;

    // number of objects written per interval
    private static final int DEFAULT_WRITE_COUNT = 500_000;

    private static final int DEFAULT_READ_COUNT = 500_000;

    // size of string in payload
    private static final int DEFAULT_PAYLOAD_SIZE = 12_000;

    // max number of objects in space
    private static final int DEFAULT_NUM_OBJECTS = 5_000_000;

    // default rate interval
    private static final int DEFAULT_RATE_INTERVAL = 5;

    private static final int DEFAULT_TIMEOUT = 3600;

    private static final int DEFAULT_LEASE_TIMEOUT = 0;

    private static String spaceName = DEFAULT_SPACE_NAME;
    private static int writeCount   = DEFAULT_WRITE_COUNT;
    private static int readCount    = DEFAULT_READ_COUNT;
    private static int payloadSize  = DEFAULT_PAYLOAD_SIZE;
    private static int maxObjects   = DEFAULT_NUM_OBJECTS;
    private static int timeout      = DEFAULT_TIMEOUT;
    private static int numberOfSites = 0;
    private static int siteId = 0;
    private static boolean bWriteCountUsed = false;
    private static int leaseTimeout = DEFAULT_LEASE_TIMEOUT;

    private static String username;
    private static String password;

    private byte[] b;

    private static AtomicInteger runCount = new AtomicInteger();


    /*
        Goal:
        Simulate:
            Ideal: 100K TPS (12K object size)

            Current: column is 7500 TPS
     */

    public MultithreadedFeeder() {
        SpaceProxyConfigurer configurer = new SpaceProxyConfigurer(spaceName);
        if( username != null && password != null ) {
            configurer.credentials(username, password);
        }
        gigaSpace = new GigaSpaceConfigurer(configurer).gigaSpace();

        createPayload();
    }

    public void prepareSpace() {
        // remove objects from previous run
        log.info("Removing objects from previous run.\n");
        Data template = new Data();
        gigaSpace.clear(template);
    }
    private void createPayload() {
        b = new byte[payloadSize];
        new Random().nextBytes(b);
    }
    private void modifyPayload() {
        int index = (int) (Math.random() * payloadSize);
        b[index] = (byte) new Random().nextInt(Byte.MAX_VALUE);
    }

    class ThreadedWriter {
        int runId;
        long[] latencies;

        ThreadedWriter(Integer id) {
            runId = id;
            latencies = new long[writeCount];

        }

        public void write() {

            log.info(String.format("Run id is: %d", runId));
            for (int i = 0; i < writeCount; i++) {
                Data data = new Data();
                Integer id = (int) (Math.random() * maxObjects);
                if( numberOfSites > 0 && siteId != 0) {
                    // to avoid conflicts, using modulo only write certain ids to a data center
                    id = id - (id % numberOfSites) + (siteId - 1);
                }
                data.setId(id);

                data.setMessage(String.format("msg  - %d", i));
                modifyPayload();
                data.setValue(b.clone());
                data.setProcessed(Boolean.FALSE);

                long before = System.nanoTime();

                if( leaseTimeout != 0) {
                    gigaSpace.write(data, (long) leaseTimeout);
                } else {
                    gigaSpace.write(data);
                }
                long after = System.nanoTime();

                latencies[i] = (after - before);

            }

            printLatencies();
            log.info(String.format("Finished run %d", runId));
        }

        public void printLatencies() {
            long sum = 0;
            long max = Long.MIN_VALUE;
            long min = Long.MAX_VALUE;

            for( int i=0; i < writeCount; i++) {
                long value = latencies[i];
                if (value < min) {
                    min = value;
                }
                if (value > max) {
                    max = value;
                }
                sum += value;
            }

            log.info(String.format("Run id: %d, Longest elapsed time:  %d (ns), %.2f(ms)",runId, max, ((double) max)/1000000));
            log.info(String.format("Run id: %d, Shortest elapsed time: %d (ns)", runId, min));
            log.info(String.format("Run id: %d, Average run time:       %.2f (ns), writeCount: %d", runId, (((double) sum) / writeCount), writeCount));
        }
    }
    class ThreadedReader {
        int runId;
        long[] latencies;

        ThreadedReader(Integer id) {
            runId = id;
            latencies = new long[readCount];
        }

        public void read() {

            log.info(String.format("Run id is: %d", runId));
            for (int i = 0; i < readCount; i++) {
                Data data = new Data();
                Integer id = (int) (Math.random() * maxObjects);
                data.setId(id);

                long before = System.nanoTime();

                Data readValue = gigaSpace.readById(Data.class, data);

                long after = System.nanoTime();

                latencies[i] = (after - before);

            }

            printLatencies();
            log.info(String.format("Finished run %d", runId));
        }

        public void printLatencies() {
            long sum = 0;
            long max = Long.MIN_VALUE;
            long min = Long.MAX_VALUE;

            for( int i=0; i < readCount; i++) {
                long value = latencies[i];
                if (value < min) {
                    min = value;
                }
                if (value > max) {
                    max = value;
                }
                sum += value;
            }

            log.info(String.format("Run id: %d, Longest elapsed time:  %d (ns), %.2f(ms)",runId, max, ((double) max)/1000000));
            log.info(String.format("Run id: %d, Shortest elapsed time: %d (ns)", runId, min));
            log.info(String.format("Run id: %d, Average run time:       %.2f (ns), readCount: %d", runId, (((double) sum) / readCount), readCount));
        }
    }

    private static int checkRange(String value, int min, int max, int defaultValue) {
        try {
            int val = Integer.parseInt(value);
            if( min <= val && val <= max ) {
                return val;
            }
        } catch (NumberFormatException nfe) {
            nfe.printStackTrace();
            return defaultValue;
        }
        return defaultValue;
    }

    public static void main(String[] args) {
        try {
            int threadCount = DEFAULT_NUM_THREADS;
            int rateInterval = DEFAULT_RATE_INTERVAL;


            int index = args.length;

            if (args[0].equalsIgnoreCase("-help")) {
                System.out.println("This program is a multi-threaded feeder.");
                System.out.println("Available arguments are:");
                System.out.println("  -numThreads x -writeCount x -rateInterval x -payloadSize x -timeout x -spaceName spaceName -numberOfSites x -site x -username x -password x");
                System.out.println("  -numThreads,   Number of threads.");
                System.out.println("       Default: " + DEFAULT_NUM_THREADS + ", Max: " + MAX_NUM_THREADS);
                System.out.println("  -writeCount,   Number of objects written per interval.");
                System.out.println("       Default: " + DEFAULT_WRITE_COUNT + ", Max: " + MAX_WRITE_COUNT);
                System.out.println("  -readCount,    Number of objects to be read per interval.");
                System.out.println("       Default: " + DEFAULT_READ_COUNT + ", Max: " + MAX_READ_COUNT);
                System.out.println("                If defined with writeCount, readCount will be ignored.");
                System.out.println("  -rateInterval, Interval (in seconds).");
                System.out.println("       Default: " + DEFAULT_RATE_INTERVAL + ", Max: " + MAX_RATE_INTERVAL);
                System.out.println("  -maxObjects,   Maximum number of objects in space.");
                System.out.println("       Default: " + DEFAULT_NUM_OBJECTS + ", Max: " + MAX_NUM_OBJECTS);
                System.out.println("  -spaceName,    Space name.");
                System.out.println("       Default: " + DEFAULT_SPACE_NAME);
                System.out.println("  -timeout,      Timeout (in seconds).");
                System.out.println("       Default: " + DEFAULT_TIMEOUT);
                System.out.println("The following parameters are used when the multi-threaded feeder is set to write objects.");
                System.out.println("  -payloadSize,  Payload size (in bytes).");
                System.out.println("       Default: " + DEFAULT_PAYLOAD_SIZE + ", Max: " + MAX_PAYLOAD_SIZE);
                System.out.println("  -leaseTimeout: Lease timeout (in milliseconds)");
                System.out.println("       Default: No lease timeout used.");
                System.out.println("  -numberOfSites, Number of sites or data centers in the WAN replication.");
                System.out.println("  -site,         Site number, used with -numberOfSites");
                System.out.println("       For example, if numberOfSites is 3, site can be: 1, 2 or 3");
                System.out.println("  -username,     username. Use if XAP cluster is secured.");
                System.out.println("  -password,     password. Use if XAP cluster is secured.");
                System.exit(0);
            }

            if (index >= 2) {

                while (index >= 2) {
                    String property = args[index - 2];
                    String value = args[index - 1];
                    if (property.equalsIgnoreCase("-numThreads")) {
                        threadCount = checkRange(value, 1, MAX_NUM_THREADS, DEFAULT_NUM_THREADS);
                    } else if (property.equalsIgnoreCase("-writeCount")) {
                        writeCount = checkRange(value, 1, MAX_WRITE_COUNT, DEFAULT_WRITE_COUNT);
                        bWriteCountUsed = true;
                    } else if (property.equalsIgnoreCase("-readCount")) {
                        readCount = checkRange(value, 1, MAX_READ_COUNT, DEFAULT_READ_COUNT);
                    } else if (property.equalsIgnoreCase("-rateInterval")) {
                        rateInterval = checkRange(value, 1, MAX_RATE_INTERVAL, DEFAULT_RATE_INTERVAL);
                    } else if (property.equalsIgnoreCase("-payloadSize")) {
                        payloadSize = checkRange(value, 1, MAX_PAYLOAD_SIZE, DEFAULT_PAYLOAD_SIZE);
                    } else if (property.equalsIgnoreCase("-maxObjects")) {
                        maxObjects = checkRange(value, 1, MAX_NUM_OBJECTS, DEFAULT_NUM_OBJECTS);
                    } else if (property.equalsIgnoreCase("-timeout")) {
                        timeout = checkRange(value, 1, MAX_TIMEOUT, DEFAULT_TIMEOUT);
                    } else if (property.equalsIgnoreCase("-spaceName")) {
                        spaceName = value;
                    } else if (property.equalsIgnoreCase("-leaseTimeout")) {
                        leaseTimeout = checkRange(value, 0, MAX_LEASE_TIMEOUT, DEFAULT_LEASE_TIMEOUT);
                    } else if (property.equalsIgnoreCase("-numberOfSites")) {
                        numberOfSites = checkRange(value, 0,MAX_NUMBER_OF_SITES, 0);
                    } else if (property.equalsIgnoreCase("-site")) {
                        siteId = checkRange(value, 0, MAX_NUMBER_OF_SITES, 0);
                    } else if (property.equalsIgnoreCase("-username")) {
                        username = value;
                    } else if (property.equalsIgnoreCase("-password")) {
                        password = value;
                    }
                    index -= 2;
                }
            }
            MultithreadedFeeder feeder = new MultithreadedFeeder();

            if( bWriteCountUsed == true ) {
                log.info("Number of threads: " + threadCount);
                log.info("Number of objects written per interval: " + writeCount);
                log.info("Interval (in seconds): " + rateInterval);
                log.info("Payload size (in bytes): " + payloadSize);
                log.info("Max number of objects in space: " + maxObjects);
                log.info("Space name: " + spaceName);
                log.info("Timeout: " + timeout);
                if( leaseTimeout != 0) {
                    log.info("Lease Timeout: " + leaseTimeout );
                }

                // check again in case numberOfSites was parsed after siteId
                siteId = checkRange(new Integer(siteId).toString(), 0, numberOfSites, 0);

                if (numberOfSites != 0 && siteId != 0) {
                    log.info("Number of sites: " + numberOfSites);
                    log.info("Site: " + siteId);
                }

                log.info(String.format("Total writes / second (goal) = ((number of threads * number of objects written) / interval): %.2f", ((double) writeCount * threadCount) / rateInterval));
            }
            else {
                log.info("Number of threads: " + threadCount);
                log.info("Number of objects read per interval: " + readCount);
                log.info("Interval (in seconds): " + rateInterval);
                log.info("Max number of objects in space: " + maxObjects);
                log.info("Space name: " + spaceName);
                log.info("Timeout: " + timeout);

                log.info(String.format("Total reads / second (goal) = ((number of threads * number of objects read) / interval): %.2f", ((double) readCount * threadCount) / rateInterval));
            }
            //feeder.prepareSpace();

            ScheduledExecutorService scheduledExecutorService =
                    Executors.newScheduledThreadPool(threadCount);

            for (int i = 0; i < threadCount; i++) {
                scheduledExecutorService.scheduleAtFixedRate(new Runnable() {
                    public void run() {
                        try {
                            if( bWriteCountUsed == true ) {
                                ThreadedWriter writer = feeder.new ThreadedWriter(runCount.getAndIncrement());
                                writer.write();
                            } else {
                                ThreadedReader reader = feeder.new ThreadedReader(runCount.getAndIncrement());
                                reader.read();
                            }
                        }
                        catch (Exception e) {
                            e.printStackTrace();
                        }
                        System.err.println("Another scheduled run...");
                    }
                }, 1, rateInterval, TimeUnit.SECONDS);
            }
            try {
                Thread.sleep((long) timeout * 1000);   // 3600 * 1000 millis = 1 hour
                scheduledExecutorService.shutdown();
                scheduledExecutorService.awaitTermination(60, TimeUnit.SECONDS);
            } catch (InterruptedException ie) {
                ie.printStackTrace();
            }
            if( bWriteCountUsed ) {
                log.info(String.format("Total objects written (number of objects written per interval * number of runs): %d ", writeCount * runCount.get()));
            }
            else {
                log.info(String.format("Total objects read (number of objects read per interval * number of runs): %d ", readCount * runCount.get()));
            }
        } catch (Throwable t) {
            t.printStackTrace();;
        }
    }

}

