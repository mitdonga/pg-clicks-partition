psql -U postgres

CREATE DATABASE cuelinks_test;
\c cuelinks_test

CREATE TABLE clicks (
	id SERIAL PRIMARY KEY,
	ip_address INET,
	country_code CHAR(2),
	campaign_id INTEGER,
	user_id INTEGER,
	channel_id INTEGER,
	traffic_source VARCHAR,
	subid1 VARCHAR,
	subid2 VARCHAR,
	subid3 VARCHAR,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clicks_partitioned (LIKE clicks INCLUDING ALL);

# View table don't inherit default values for (id, created_at) therefore we'll add manually
CREATE OR REPLACE VIEW clicks_partitioned_view AS SELECT * FROM clicks_partitioned;

ALTER VIEW clicks_partitioned_view
ALTER COLUMN id
SET DEFAULT nextval('clicks_id_seq'::regclass);

ALTER VIEW clicks_partitioned_view
ALTER COLUMN created_at
SET DEFAULT CURRENT_TIMESTAMP;

CREATE TRIGGER clicks_partitioned_view_insert_trigger
INSTEAD OF INSERT ON clicks_partitioned_view
FOR EACH ROW EXECUTE PROCEDURE clicks_partitioned_view_insert_trigger_procedure();

