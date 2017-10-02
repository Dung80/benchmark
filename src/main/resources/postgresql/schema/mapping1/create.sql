/* Table creation statements for PostgreSQL */

CREATE TABLE SEMANTIC_ENTITY (
  ID varchar(255) NOT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE REGION (
  ID varchar(255) NOT NULL,
  FLOOR float NOT NULL,
  NAME varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE LOCATION (
  ID varchar(255) NOT NULL,
  X float NOT NULL,
  Y float NOT NULL,
  Z float NOT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE REGION_LOCATION (
  LOCATION_ID varchar(255) NOT NULL,
  REGION_ID varchar(255) NOT NULL,
   PRIMARY KEY(LOCATION_ID, REGION_ID),
   FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION (ID),
   FOREIGN KEY (REGION_ID) REFERENCES REGION (ID)
) ;

CREATE TABLE INFRASTRUCTURE_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE INFRASTRUCTURE (
  NAME varchar(255) DEFAULT NULL,
  INFRASTRUCTURE_TYPE_ID varchar(255) DEFAULT NULL,
  ID varchar(255) NOT NULL,
  REGION_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (INFRASTRUCTURE_TYPE_ID) REFERENCES INFRASTRUCTURE_TYPE (ID),
   FOREIGN KEY (REGION_ID) REFERENCES REGION (ID),
   FOREIGN KEY (ID) REFERENCES SEMANTIC_ENTITY (ID)
) ;

CREATE TABLE PLATFORM_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  IMAGEPATH varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL UNIQUE,
  MOBILITY varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE USERS (
  EMAIL varchar(255) DEFAULT NULL UNIQUE,
  GOOGLE_AUTH_TOKEN varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  ID varchar(255) NOT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (ID) REFERENCES SEMANTIC_ENTITY (ID)
 ) ;

CREATE TABLE USER_GROUP (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE USER_GROUP_MEMBERSHIP (
  USER_ID varchar(255) NOT NULL,
  USER_GROUP_ID varchar(255) NOT NULL,
  PRIMARY KEY (USER_GROUP_ID, USER_ID),
   FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
   FOREIGN KEY (USER_GROUP_ID) REFERENCES USER_GROUP (ID)
) ;

CREATE TABLE PLATFORM (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  LOCATION_ID varchar(255) DEFAULT NULL,
  USER_ID varchar(255) DEFAULT NULL,
  PLATFORM_TYPE_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (USER_ID) REFERENCES USERS (ID),
   FOREIGN KEY (PLATFORM_TYPE_ID) REFERENCES PLATFORM_TYPE (ID),
   FOREIGN KEY (LOCATION_ID) REFERENCES LOCATION (ID)
) ;

CREATE TABLE SENSOR_COVERAGE (
  ID varchar(255) NOT NULL,
  RADIUS float NOT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE COVERAGE_INFRASTRUCTURE (
  ID varchar(255) NOT NULL,
  INFRASTRUCTURE_ID varchar(255) NOT NULL,
  PRIMARY KEY (INFRASTRUCTURE_ID, ID),
   FOREIGN KEY (INFRASTRUCTURE_ID) REFERENCES INFRASTRUCTURE (ID),
   FOREIGN KEY (ID) REFERENCES SENSOR_COVERAGE (ID)
) ;

CREATE TABLE OBSERVATION_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL UNIQUE,
  PAYLOAD_SCHEMA varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE sensor_capture_functionality (
  ID varchar(255) NOT NULL,
  mechanism varchar(255) DEFAULT NULL,
  sensorAddress varchar(255) DEFAULT NULL,
  type varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE SENSOR_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  IMAGE_PATH varchar(255) DEFAULT NULL,
  MOBILITY varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  CAPTURE_FUNCTIONALITY_ID varchar(255) DEFAULT NULL,
  OBSERVATION_TYPE_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (OBSERVATION_TYPE_ID) REFERENCES OBSERVATION_TYPE (ID),
   FOREIGN KEY (CAPTURE_FUNCTIONALITY_ID) REFERENCES sensor_capture_functionality (ID)
) ;

CREATE TABLE SENSOR (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  SENSOR_IP varchar(255) DEFAULT NULL,
  SENSOR_PORT varchar(255) DEFAULT NULL,
  COVERAGE_ID varchar(255) DEFAULT NULL,
  INFRASTRUCTURE_ID varchar(255) DEFAULT NULL,
  USER_ID varchar(255) DEFAULT NULL,
  PLATFORM_ID varchar(255) DEFAULT NULL,
  SENSOR_TYPE_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (SENSOR_TYPE_ID) REFERENCES SENSOR_TYPE (ID),
   FOREIGN KEY (INFRASTRUCTURE_ID) REFERENCES INFRASTRUCTURE (ID),
   FOREIGN KEY (COVERAGE_ID) REFERENCES SENSOR_COVERAGE (ID),
   FOREIGN KEY (PLATFORM_ID) REFERENCES PLATFORM (ID),
   FOREIGN KEY (USER_ID) REFERENCES USERS (ID)
) ;

CREATE TABLE OBSERVATION (
  id varchar(255) NOT NULL,
  payload varchar(255) DEFAULT NULL,
  timeStamp timestamp NOT NULL,
  sensor_id varchar(255) DEFAULT NULL,
  observation_type_id varchar(255) DEFAULT NULL,
  PRIMARY KEY (id),
   FOREIGN KEY (sensor_id) REFERENCES SENSOR (ID),
   FOREIGN KEY (observation_type_id) REFERENCES OBSERVATION_TYPE (ID)
) ;

CREATE TABLE SEMANTIC_OBSERVATION_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  PAYLOAD_SCHEMA varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID)
) ;

CREATE TABLE VIRTUAL_SENSOR_TYPE (
  ID varchar(255) NOT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  SEMANTIC_OBSERVATION_TYPE_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (id),
   FOREIGN KEY (SEMANTIC_OBSERVATION_TYPE_ID) REFERENCES SEMANTIC_OBSERVATION_TYPE (ID)
) ;

CREATE TABLE VIRTUAL_SENSOR (
  ID varchar(255) NOT NULL,
  COMPLIE_COMMAND varchar(255) DEFAULT NULL,
  COMPILE_DIRECTORY varchar(255) DEFAULT NULL,
  COMPILED_CODE_LOCATION varchar(255) DEFAULT NULL,
  DESCRIPTION varchar(255) DEFAULT NULL,
  EXECUTE_COMMAND varchar(255) DEFAULT NULL,
  EXECUTE_DIRECTORY varchar(255) DEFAULT NULL,
  LANGUAGE varchar(255) DEFAULT NULL,
  NAME varchar(255) DEFAULT NULL,
  PROJECT_NAME varchar(255) DEFAULT NULL,
  SOURCE_FILE_LOCATION varchar(255) DEFAULT NULL,
  VS_TYPE_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (ID),
   FOREIGN KEY (VS_TYPE_ID) REFERENCES VIRTUAL_SENSOR_TYPE (ID)
) ;

CREATE TABLE SEMANTIC_OBSERVATION (
  ID varchar(255) NOT NULL,
  CONFIDENCE float NOT NULL,
  PAYLOAD varchar(255) DEFAULT NULL,
  TIMESTAMP timestamp NOT NULL,
  SEMANTIC_ENTITY_ID varchar(255) DEFAULT NULL,
  SEMANTIC_OBSERVATION_TYPE_ID varchar(255) DEFAULT NULL,
  VIRTUAL_SENSOR_ID varchar(255) DEFAULT NULL,
  PRIMARY KEY (id),
   FOREIGN KEY (VIRTUAL_SENSOR_ID) REFERENCES VIRTUAL_SENSOR (ID),
   FOREIGN KEY (SEMANTIC_OBSERVATION_TYPE_ID) REFERENCES SEMANTIC_OBSERVATION_TYPE (id)
) ;

