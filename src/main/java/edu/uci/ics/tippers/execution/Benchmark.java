package edu.uci.ics.tippers.execution;

import edu.uci.ics.tippers.common.Database;
import edu.uci.ics.tippers.common.ReportFormat;
import edu.uci.ics.tippers.data.BaseDataUploader;
import edu.uci.ics.tippers.data.asterixdb.AsterixDBDataUploader;
import edu.uci.ics.tippers.data.griddb.GridDBDataUploader;
import edu.uci.ics.tippers.exception.BenchmarkException;
import edu.uci.ics.tippers.query.BaseQueryManager;
import edu.uci.ics.tippers.query.asterixdb.AsterixDBQueryManager;
import edu.uci.ics.tippers.query.griddb.GridDBQueryManager;
import edu.uci.ics.tippers.schema.BaseSchema;
import edu.uci.ics.tippers.schema.asterixdb.AsterixDBSchema;
import edu.uci.ics.tippers.schema.griddb.GridDBSchema;
import javafx.util.Pair;
import org.ini4j.Ini;
import org.ini4j.IniPreferences;

import java.io.File;
import java.io.IOException;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.prefs.Preferences;

/* Main class to be run to start the benchmark
 */
public class Benchmark {

    private static String CONFIG = "benchmark.ini";
    private static Map<Pair<Database, Integer>, Map<Integer, Duration>> runTimes = new HashMap<>();
    private static Configuration configuration;

    private Configuration readConfiguration() throws BenchmarkException {
        try {
            Ini ini = new Ini(new File(getClass().getClassLoader().getResource(CONFIG).getFile()));
            Preferences prefs = new IniPreferences(ini);
            configuration = new Configuration(prefs);

        } catch (IOException e) {
            e.printStackTrace();
            throw new BenchmarkException("Error reading Configuration File");
        }
        return null;
    }

    private void runBenchmark(BaseSchema schemaCreator, BaseDataUploader dataUploader, BaseQueryManager queryManager) {

        try {
            // Creating schema on a particular database and particular mapping
            // schemaCreator.createSchema();

            // Inserting data into the database system after schema creation
            //dataUploader.addAllData();

            // Running benchmark queries and gathering query runtimes
            runTimes.put(new Pair<>(queryManager.getDatabase(), queryManager.getMapping()), queryManager.runQueries());

            // Cleaning up inserted data and dropping created schema
            //schemaCreator.dropSchema();
        } catch (BenchmarkException be) {
            be.printStackTrace();
        }
    }

    public static void main(String args[]) {
        Benchmark benchmark = new Benchmark();

        try {
            benchmark.readConfiguration();
            DBMSManager dbmsManager = new DBMSManager(configuration.getScriptsDir());
            //dbmsManager.startServers();

            for (Database database: configuration.getDatabases()) {
                switch (database) {
                    case GRIDDB:
                        configuration.getMappings().get(Database.GRIDDB).forEach(
                                e->benchmark.runBenchmark(
                                        new GridDBSchema(e), new GridDBDataUploader(e, configuration.getDataDir()),
                                        new GridDBQueryManager(e, false)));
                        break;
                    case CRATEDB:
                        break;
                    case MONGODB:
                        break;
                    case ASTERIXDB:
                        configuration.getMappings().get(Database.GRIDDB).forEach(
                                e->benchmark.runBenchmark(
                                        new AsterixDBSchema(e), new AsterixDBDataUploader(e, configuration.getDataDir()),
                                        new AsterixDBQueryManager(e, false)));
                        break;
                    case CASSANDRA:
                        break;
                    case POSTGRESQL:
                        break;
                    default:
                        throw new BenchmarkException("Database Not Supported");
                }
            }

            ReportBuilder builder = new ReportBuilder(runTimes, ReportFormat.TEXT);
            builder.createReport();

            //dbmsManager.stopServers();
        } catch (BenchmarkException e) {
            e.printStackTrace();
        }
    }

}
