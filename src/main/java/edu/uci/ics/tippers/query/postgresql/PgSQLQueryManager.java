package edu.uci.ics.tippers.query.postgresql;

import edu.uci.ics.tippers.common.Database;
import edu.uci.ics.tippers.common.constants.Constants;
import edu.uci.ics.tippers.connection.postgresql.PgSQLConnectionManager;
import edu.uci.ics.tippers.exception.BenchmarkException;
import edu.uci.ics.tippers.query.BaseQueryManager;
import edu.uci.ics.tippers.writer.RowWriter;
import org.json.JSONObject;

import java.io.IOException;
import java.sql.*;
import java.time.Duration;
import java.time.Instant;
import java.util.Date;
import java.util.List;

import static edu.uci.ics.tippers.common.util.Helper.getFileFromQuery;

public class PgSQLQueryManager extends BaseQueryManager{

    private Connection connection;

    // Needed For External Databases
    private Database database = Database.POSTGRESQL;

    public PgSQLQueryManager(int mapping, String queriesDir, String outputDir, boolean writeOutput, long timeout) {
        super(mapping, queriesDir, outputDir, writeOutput, timeout);
        connection = PgSQLConnectionManager.getInstance().getConnection();
    }

    // For External Database (CrateDB) Usage
    public PgSQLQueryManager( int mapping, String queriesDir, String outputDir, boolean writeOutput, long timeout,
                             Connection connection) {
        super(mapping, queriesDir, outputDir, writeOutput, timeout);
        this.connection = connection;
        this.database = Database.CRATEDB;
    }

    public Duration runTimedQuery(PreparedStatement stmt, int queryNum) throws BenchmarkException {
        try {
            Instant start = Instant.now();
            ResultSet rs = stmt.executeQuery();
            ResultSetMetaData rsmd = rs.getMetaData();
            int columnsNumber = rsmd.getColumnCount();

            RowWriter<String> writer = new RowWriter<>(outputDir, getDatabase(), mapping, getFileFromQuery(queryNum));
            while(rs.next()) {
                if (writeOutput) {
                    StringBuilder line = new StringBuilder("");
                    for(int i = 1; i <= columnsNumber; i++)
                        line.append(rs.getString(i)).append("\t");
                    writer.writeString(line.toString());
                }
            }
            writer.close();
            rs.close();
            Instant end = Instant.now();
            return Duration.between(start, end);
        } catch (SQLException | IOException e) {
            e.printStackTrace();
            throw new BenchmarkException("Error Running Query");
        }
    }


    @Override
    public Database getDatabase() {
        return database;
    }

    @Override
    public void cleanUp() {

    }

    @Override
    public Duration runQuery1(String sensorId) throws BenchmarkException {
        switch (mapping) {
            case 1:
                String query = "SELECT name FROM SENSOR WHERE id=?";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);
                    stmt.setString(1, sensorId);
                    return runTimedQuery(stmt, 1);
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }

    @Override
    public Duration runQuery2(String sensorTypeName, List<String> locationIds) throws BenchmarkException {
        switch (mapping) {
            case 1:
                String query = "SELECT sen.name FROM SENSOR sen, SENSOR_TYPE st, SENSOR_COVERAGE sc, " +
                        "COVERAGE_INFRASTRUCTURE ci WHERE sen.SENSOR_TYPE_ID=st.id AND st.name=? " +
                        "AND sen.COVERAGE_ID=sc.id AND sc.id=ci.id AND ci.INFRASTRUCTURE_ID=ANY(?)";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);
                    stmt.setString(1, sensorTypeName);

                    Array locationsArray = connection.createArrayOf("VARCHAR", locationIds.toArray());
                    stmt.setArray(2, locationsArray);
                    return runTimedQuery(stmt, 2);
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }

    @Override
    public Duration runQuery3(String sensorId, Date startTime, Date endTime) throws BenchmarkException {
        switch (mapping) {
            case 1:
                String query = "SELECT timeStamp, payload FROM OBSERVATION WHERE timestamp>? AND timestamp<? " +
                        "AND SENSOR_ID=?";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);
                    stmt.setTimestamp(1, new Timestamp(startTime.getTime()));
                    stmt.setTimestamp(2, new Timestamp(endTime.getTime()));
                    stmt.setString(3, sensorId);

                    return runTimedQuery(stmt, 3);
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }

    @Override
    public Duration runQuery4(List<String> sensorIds, Date startTime, Date endTime) throws BenchmarkException {
        switch (mapping) {
            case 1:
                String query = "SELECT timeStamp, payload FROM OBSERVATION WHERE timestamp>? AND timestamp<? " +
                        "AND SENSOR_ID = ANY(?)";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);
                    stmt.setTimestamp(1, new Timestamp(startTime.getTime()));
                    stmt.setTimestamp(2, new Timestamp(endTime.getTime()));

                    Array sensorIdArray = connection.createArrayOf("VARCHAR", sensorIds.toArray());
                    stmt.setArray(3, sensorIdArray);

                    return runTimedQuery(stmt, 4);
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }

    @Override
    public Duration runQuery5(String sensorTypeName, Date startTime, Date endTime, String payloadAttribute,
                              Object startPayloadValue, Object endPayloadValue) throws BenchmarkException {
        switch (mapping) {
            case 1:
                Instant start = Instant.now();
                String query = "SELECT timeStamp, payload FROM OBSERVATION o, SENSOR s, SENSOR_TYPE st  " +
                        "WHERE s.id = o.sensor_id AND s.sensor_type_id=st.id AND st.name=? AND " +
                        "timestamp>? AND timestamp<? ";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);

                    stmt.setString(1, sensorTypeName);
                    stmt.setTimestamp(2, new Timestamp(startTime.getTime()));
                    stmt.setTimestamp(3, new Timestamp(endTime.getTime()));

                    ResultSet rs = stmt.executeQuery();
                    ResultSetMetaData rsmd = rs.getMetaData();
                    int columnsNumber = rsmd.getColumnCount();
                    int payloadColNum = 1;

                    for(int i = 1; i <= columnsNumber; i++) {
                        if ("payload".equals(rsmd.getColumnName(i))) {
                            payloadColNum = i;
                        }
                    }
                    RowWriter<String> writer = new RowWriter<>(outputDir, getDatabase(), mapping, getFileFromQuery(5));
                    while(rs.next()) {
                        JSONObject payload = new JSONObject(rs.getString(payloadColNum));

                        if (startPayloadValue instanceof  Integer) {
                            if (payload.getInt(payloadAttribute) >= (Integer)startPayloadValue
                                    && payload.getInt(payloadAttribute) <= (Integer)endPayloadValue) {
                                if (writeOutput) {
                                    StringBuilder line = new StringBuilder("");
                                    for(int i = 1; i <= columnsNumber; i++)
                                        line.append(rs.getString(i)).append("\t");
                                    writer.writeString(line.toString());
                                }
                            }

                        } else if (startPayloadValue instanceof  Double) {
                            if (payload.getDouble(payloadAttribute) >= (Double)startPayloadValue
                                    && payload.getDouble(payloadAttribute) <= (Double)endPayloadValue) {
                                if (writeOutput) {
                                    StringBuilder line = new StringBuilder("");
                                    for(int i = 1; i <= columnsNumber; i++)
                                        line.append(rs.getString(i)).append("\t");
                                    writer.writeString(line.toString());
                                }
                            }

                        }
                    }
                    writer.close();
                    rs.close();
                    Instant end = Instant.now();
                    return Duration.between(start, end);
                } catch (SQLException | IOException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }

    @Override
    public Duration runQuery6(List<String> sensorIds, Date startTime, Date endTime) throws BenchmarkException {
        switch (mapping) {
            case 1:
                String query = "SELECT obs.sensor_id, avg(counts) FROM " +
                        "(SELECT sensor_id, date_trunc('day', timestamp), " +
                        "count(*) as counts " +
                        "FROM OBSERVATION WHERE timestamp>? AND timestamp<? " +
                        "AND SENSOR_ID = ANY(?) GROUP BY sensor_id, date_trunc('day', timestamp)) " +
                        "AS obs GROUP BY sensor_id";
                try {
                    PreparedStatement stmt = connection.prepareStatement(query);
                    stmt.setTimestamp(1, new Timestamp(startTime.getTime()));
                    stmt.setTimestamp(2, new Timestamp(endTime.getTime()));

                    Array sensorIdArray = connection.createArrayOf("VARCHAR", sensorIds.toArray());
                    stmt.setArray(3, sensorIdArray);

                    return runTimedQuery(stmt, 6);
                } catch (SQLException e) {
                    e.printStackTrace();
                    throw new BenchmarkException("Error Running Query");
                }
            default:
                throw new BenchmarkException("No Such Mapping");
        }
    }
}