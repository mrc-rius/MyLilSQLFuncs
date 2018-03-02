-- Procedure to historify tables 
-- only requires that both table have same DDL and a field called fecha_insercion
-- PARAM: number_days_h <0 means number of days that a table is historified
      --  number_days_h =0 means 1 day of historification
      --  number_days_h >0 means 0 day of historification and deletes all historified data. But not the last day.

DROP PROCEDURE IF EXISTS p_dwh_historificar_table;
CREATE PROCEDURE p_dwh_historificar_table(IN source_table varchar(200),IN end_table varchar(200), IN number_days_h INTEGER, OUT status_execution INTEGER)
BEGIN
  -- DECLARES AND INIT SET
  SET status_execution=0;

  -- ONLY IF PARAMS ARE FULLFILLED
    IF source_table is not null and end_table is not null then
      -- PREPARE CREATE TABLE IF NOT EXISTS STATEMENT
        SET create_sql=CONCAT_WS(' ','CREATE TABLE IF NOT EXISTS',end_table,'AS SELECT * FROM',source_table,'WHERE 1=2;');
      PREPARE stmt FROM create_sql ;
      -- EXECUTE STATEMENT
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- PREPARE DELETE DESTINY TABLE
        SET delete_sql=CONCAT_WS(' ','DELETE FROM',end_table,'WHERE date_format(fecha_insercion,''%Y%m%d'')<(SELECT date_format(DATE_ADD(max(fecha_insercion),INTERVAL',number_days_h,'DAY),''%Y%m%d'') as fecha_insercion from',source_table,'as source);');
        PREPARE stmt FROM delete_sql ;
      -- EXECUTE STATEMENT
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

      -- PREPARE INSERT INTO @destiny_table TABLE STATEMENT
        SET insert_sql=CONCAT_WS(' ','INSERT INTO',end_table,'SELECT * FROM',source_table,' as source where date_format(source.fecha_insercion,''%Y%m%d'') not in (SELECT (date_format(fecha_insercion,''%Y%m%d'')) as fecha_insercion from',end_table,');');
      -- EXECUTE STATEMENT
        PREPARE stmt FROM insert_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

      -- SET STATUS OK
        SET status_execution=1;
    END IF;
END;





