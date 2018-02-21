CREATE OR REPLACE FUNCTION p_delete_table_day_interval(date_field_name TEXT, interval_days TEXT, t_schema TEXT, table_name TEXT)
  returns INTEGER AS $func$
    BEGIN
      BEGIN
        EXECUTE (SELECT FORMAT('delete from %s.%s where %s<(SELECT * FROM (SELECT max(%s) - INTERVAL ''%s''  FROM %s.%s) aux_date);',t_schema,table_name,date_field_name,date_field_name,interval_days,t_schema,table_name));
        EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'ERROR WITH THE SQL STATEMENT: delete from %.% where %<( SELECT * FROM (SELECT max(%) - INTERVAL ''%'' FROM %.%) aux_date);',t_schema,table_name,date_field_name,date_field_name,interval_days,t_schema,table_name;
      END;
    RETURN 1;
    END;
  $func$ LANGUAGE plpgsql
  SECURITY DEFINER;