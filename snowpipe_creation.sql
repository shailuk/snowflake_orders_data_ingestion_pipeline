-- Use role 
use role accountadmin;

-- Create Target Database
create or replace database snowpipe_dev; 

use snowpipe_dev; 

-- Create Target Table 
create or replace table orders_data_lz(
    order_id int,
    product varchar(20),
    quantity int,
    order_status varchar(30),
    order_date date);

--- Storage Integration - A Storage Integration in Snowflake is a secure, named object that allows Snowflake to connect to external cloud storage
CREATE OR REPLACE STORAGE INTEGRATION s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://rootshailesh1/snowpipe_project/')  -- This is in the bucket level
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::060662064877:role/Snowflake_Storage_Integration_Role';

-- Get the S3 Integration details
DESC INTEGRATION s3_integration;

-- Create a file format (e.g., CSV, JSON, Avro, Parquet)
CREATE OR REPLACE FILE FORMAT orders_data_csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null'); 

-- A stage in Snowflake refers to a location (internal or external) where data files are uploaded, stored, and prepared 
-- before being loaded into Snowflake tables.
CREATE OR REPLACE STAGE snowpipe_stage
url = 's3://rootshailesh1/snowpipe_project/'  -- This is at folder level
storage_integration = s3_integration;

-- Get the stages details
show stages;

-- List files within a stage 
list @snowpipe_stage

-- Create Snowpipe 
CREATE OR REPLACE PIPE my_event_pipe
AUTO_INGEST = TRUE AS
COPY INTO orders_data_lz
FROM @snowpipe_stage; 

--list all the pipes
show pipes; 

-- Check the status of the Pipe 
select system$pipe_status('MY_EVENT_PIPE')

/*
{"executionState":"RUNNING","pendingFileCount":0,
"lastIngestedTimestamp":"2026-07-06T11:22:04.667Z","lastIngestedFilePath":"orders_20241228.csv",
"notificationChannelName":"arn:aws:sqs:us-east-1:059898286749:sf-snowpipe-AIDAQ34RXKKO4DKTKLRVU-QYBg8WNCxSJCE1TIIZYYiw",
"numOutstandingMessagesOnChannel":1,
"lastReceivedMessageTimestamp":"2026-07-06T11:13:51.883Z",
"lastPulledFromChannelTimestamp":"2026-07-06T11:27:01.845Z",
"pendingHistoryRefreshJobsCount":0}
*/

-- Check the history of copy command on a table
SELECT * FROM TABLE(information_schema.pipe_usage_history(
    date_range_start=>dateadd('day',-1,current_date()),
    pipe_name=>'my_event_pipe'));

--- Check if the data is loaded into the table 
SELECT * FROM orders_data_lz LIMIT 5;

-- Force the snowpipe to scan the stage 
ALTER PIPE my_event_pipe REFRESH;

-- Pause the pipe
ALTER PIPE my_event_pipe SET PIPE_EXECUTION_PAUSED = true;

-- Terminate or delete pipe 
drop pipe my_event_pipe; 


