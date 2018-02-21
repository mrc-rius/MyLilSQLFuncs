
CREATE OR REPLACE FUNCTION p_historizice_table(origin_table TEXT, date_field_name TEXT)
  RETURNS INTEGER AS $func$
DECLARE
  columns TEXT;
BEGIN
  -- Retrieve origin table columns
  SELECT string_agg(column_name, ',')
  INTO columns
  FROM information_schema.columns
  WHERE table_schema = 'kernel'
        AND table_name = 'krl_tablon_variables_filtrado_campañas';

  -- Prepare tables to historify data
  BEGIN
    EXECUTE (SELECT FORMAT('CREATE TABLE IF NOT EXISTS %s_h (LIKE %s INCLUDING INDEXES);', origin_table, origin_table));
    EXCEPTION
    WHEN OTHERS
      THEN RAISE NOTICE 'ERROR CREATING TABLE - SQL STATEMENT--> CREATE TABLE IF NOT EXISTS %_h (LIKE % INCLUDING INDEXES);', origin_table, origin_table;
  END;
  BEGIN
      EXECUTE (SELECT
                 FORMAT('ALTER TABLE %s_h ADD COLUMN historiziced_timestamp timestamp DEFAULT NOW();', origin_table));
      EXCEPTION
      WHEN OTHERS
        THEN RAISE NOTICE 'ERROR ALTERING TABLE - SQL STATEMENT--> ALTER TABLE %_h ADD COLUMN historiziced_timestamp timestamp;', origin_table;
  END;

  --Insert new data

  BEGIN
    EXECUTE (SELECT FORMAT(
        'INSERT INTO %s_h (%s) SELECT %s FROM %s as dayli_table WHERE dayli_table.%s>(SELECT COALESCE(max(%s),''1900-01-01 00:00:00.000000'') from %s_h);',
        origin_table, columns, columns, origin_table, date_field_name, date_field_name, origin_table));
    EXCEPTION
    WHEN OTHERS
      THEN RAISE EXCEPTION 'There is some error in insert step for historizice table - SQL STATEMENT --> INSERT INTO %_h (%) SELECT % FROM % as dayli_table WHERE dayli_table.%>(SELECT COALESCE(max(%),''1900-01-01 00:00:00.000000'') from %_h);', origin_table, columns, columns, origin_table, date_field_name, date_field_name, origin_table;
        RETURN -1;
  END;

  -- Delete all inserted data, leaving the daily data in the parameter table

  BEGIN
    EXECUTE (SELECT FORMAT('DELETE FROM %s WHERE to_date(to_char(%s,''YYYY-MM-DD''),''YYYY-MM-DD'')!=(SELECT to_date(to_char(MAX(%s),''YYYY-MM-DD''),''YYYY-MM-DD'') FROM %s);', origin_table,date_field_name, date_field_name, origin_table));
    EXCEPTION
    WHEN OTHERS
      THEN RAISE EXCEPTION 'Error deleting rows - SQL STATEMENT - DELETE FROM % WHERE to_date(to_char(%,''YYYY-MM-DD''),''YYYY-MM-DD'')!=(SELECT to_date(to_char(MAX(%),''YYYY-MM-DD''),''YYYY-MM-DD'') FROM %)', origin_table, date_field_name, date_field_name, origin_table;
  END;

  RETURN 1;
END;
$func$ LANGUAGE plpgsql;