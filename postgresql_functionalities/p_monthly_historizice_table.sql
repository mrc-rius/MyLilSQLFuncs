CREATE OR REPLACE FUNCTION p_monthly_historizice_table(origin_table TEXT, date_field_name TEXT , t_schema TEXT)
  RETURNS INTEGER AS $func$
DECLARE
  columns TEXT;
BEGIN
  -- Retrieve origin table columns
  SELECT string_agg(column_name, ',')
  INTO columns
  FROM information_schema.columns
  WHERE table_schema = ''||t_schema||''
        AND table_name = ''||origin_table||'';

  -- Prepare tables to historify data
  BEGIN
    EXECUTE (SELECT FORMAT('CREATE TABLE IF NOT EXISTS %s.%s_monthly_h (LIKE %s.%s INCLUDING INDEXES);', t_schema,origin_table, t_schema,origin_table));
    EXCEPTION
    WHEN OTHERS
      THEN RAISE NOTICE 'ERROR CREATING TABLE - SQL STATEMENT--> CREATE TABLE IF NOT EXISTS %.%_monthly_h (LIKE %.% INCLUDING INDEXES);',  t_schema,origin_table, table_schema,origin_table;
  END;
  BEGIN
      EXECUTE (SELECT
                 FORMAT('ALTER TABLE %s.%s_monthly_h ADD COLUMN historiziced_timestamp timestamp DEFAULT NOW();', t_schema,origin_table));
      EXCEPTION
      WHEN OTHERS
        THEN RAISE NOTICE 'ERROR ALTERING TABLE - SQL STATEMENT--> ALTER TABLE %.%_monthly_h ADD COLUMN historiziced_timestamp timestamp;', t_schema,origin_table;
  END;

  --Insert new data

  BEGIN
    EXECUTE (SELECT FORMAT(
        'INSERT INTO %s.%s_monthly_h (%s) SELECT %s FROM %s.%s as dayli_table WHERE to_char(dayli_table.%s,''dd-mm-yyyy'')=(SELECT to_char(DATE_TRUNC(''MONTH'', current_timestamp) - INTERVAL ''1 DAY'',''dd-mm-yyyy''));',
        t_schema,origin_table, columns, columns, t_schema,origin_table, date_field_name));
    EXCEPTION
    WHEN OTHERS
      THEN RAISE EXCEPTION 'There is some error in insert step for historizice table - SQL STATEMENT --> INSERT INTO %.%_monthly_h (%) SELECT % FROM %.% as dayli_table WHERE to_char(dayli_table.%,''dd-mm-yyyy'')=(SELECT to_char(DATE_TRUNC(''MONTH'', current_timestamp) - INTERVAL ''1 DAY'',''dd-mm-yyyy''));',
        t_schema,origin_table, columns, columns, t_schema,origin_table, date_field_name;
  END;

  RETURN 1;
END;
$func$ LANGUAGE plpgsql
SECURITY DEFINER;