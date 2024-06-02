CREATE OR REPLACE FUNCTION clicks_partitioned_view_insert_trigger_procedure() RETURNS TRIGGER AS $BODY$
  DECLARE
    _table_name     TEXT;
    _partition_date TEXT;
  BEGIN

    /* Build a name for a new table */

		_partition_date     := date_trunc('day', NEW.created_at);
    _table_name         := 'clicks' || '_' || to_char(NEW.created_at, 'YYYYMMDD');

    /*
    Create a child table, if necessary. Announce it to all interested parties.
    */

    IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname = _table_name) THEN

      RAISE NOTICE 'A new clicks partition will be created: %', _table_name;

      /*
      Here is what happens below:
      * we inherit a table from a master table;
      * we create CHECK constraints for a resulting table.
        It means, that a record not meeting our requirements
        would not be inserted;
      * we create a necessary index;
      * triple quotes are a feature, not a bug!
      */

    EXECUTE 'CREATE TABLE IF NOT EXISTS ' || _table_name || ' (CHECK (
			user_id IS NOT NULL AND campaign_id IS NOT NULL AND
      created_at >= ''' || _partition_date::timestamp || ''' AND
      created_at  < ''' || _partition_date::timestamp + INTERVAL '1 day' || '''))
      INHERITS (clicks_partitioned);';

    EXECUTE 'CREATE INDEX IF NOT EXISTS ' || _table_name || '_on_user_id ON ' || _table_name || ' (user_id);';

  END IF;

  /* And, finally, insert. */

  EXECUTE 'INSERT INTO ' || _table_name || ' VALUES ($1.*)' USING NEW;

  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;