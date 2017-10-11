

CREATE TABLE IF NOT EXISTS REGION (
  ID string NOT NULL,
  FLOOR float NOT NULL,
  NAME string,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS LOCATION (
  ID string NOT NULL,
  X float NOT NULL,
  Y float NOT NULL,
  Z float NOT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS REGION_LOCATION (
  LOCATION_ID string NOT NULL,
  REGION_ID string NOT NULL,
   PRIMARY KEY(LOCATION_ID, REGION_ID)
) ;

CREATE TABLE IF NOT EXISTS INFRASTRUCTURE_TYPE (
  ID string NOT NULL,
  DESCRIPTION string ,
  NAME string,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS INFRASTRUCTURE (
  NAME string ,
  INFRASTRUCTURE_TYPE_ID string ,
  ID string NOT NULL,
  FLOOR integer ,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS PLATFORM_TYPE (
  ID string NOT NULL,
  DESCRIPTION string ,
  NAME string,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS USERS (
  EMAIL string,
  GOOGLE_AUTH_TOKEN string ,
  NAME string ,
  ID string NOT NULL,
  PRIMARY KEY (ID)
 ) ;

CREATE TABLE IF NOT EXISTS USER_GROUP (
  ID string NOT NULL,
  DESCRIPTION string ,
  NAME string ,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS USER_GROUP_MEMBERSHIP (
  USER_ID string NOT NULL,
  USER_GROUP_ID string NOT NULL,
  PRIMARY KEY (USER_GROUP_ID, USER_ID)
) ;

CREATE TABLE IF NOT EXISTS PLATFORM (
  ID string NOT NULL,
  NAME string ,
  USER_ID string ,
  PLATFORM_TYPE_ID string ,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS SENSOR_TYPE (
  ID string NOT NULL,
  DESCRIPTION string ,
  MOBILITY string ,
  NAME string ,
  CAPTURE_FUNCTIONALITY string ,
  PAYLOAD_SCHEMA string,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS SENSOR (
  ID string NOT NULL,
  NAME string ,
  INFRASTRUCTURE_ID string ,
  USER_ID string ,
  SENSOR_TYPE_ID string ,
  SENSOR_CONFIG string,
  PRIMARY KEY (ID)
) ;

CREATE TABLE IF NOT EXISTS COVERAGE_INFRASTRUCTURE (
  SENSOR_ID string NOT NULL,
  INFRASTRUCTURE_ID string NOT NULL,
  PRIMARY KEY (INFRASTRUCTURE_ID, SENSOR_ID)
) ;

CREATE TABLE WeMoObservation (
  id varchar(255) NOT NULL,
  currentMilliWatts integer ,
  onTodaySeconds integer,
  timeStamp timestamp NOT NULL,
  sensor_id varchar(255),
  PRIMARY KEY (id)
) ;

CREATE TABLE WiFiAPObservation (
  id varchar(255) NOT NULL,
  clientId varchar(255) ,
  timeStamp timestamp NOT NULL,
  sensor_id varchar(255) ,
  PRIMARY KEY (id)
) ;

CREATE TABLE ThermometerObservation (
  id varchar(255) NOT NULL,
  temperature integer ,
  timeStamp timestamp NOT NULL,
  sensor_id varchar(255),
  PRIMARY KEY (id)
) ;



