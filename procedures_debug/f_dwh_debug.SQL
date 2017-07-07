DELIMITER //
CREATE FUNCTION f_dwh_debug(object_debugged VARCHAR(255),variable_name VARCHAR(255),variable_value TEXT) RETURNS INTEGER(11)
	BEGIN
		DECLARE last_id INTEGER;
		INSERT INTO `dwh_debug` (object_debugged, variable_name, variable_value) VALUES (object_debugged,variable_name,variable_value);
        
		SELECT LAST_INSERT_ID() INTO @last_id;
        RETURN @last_id;
	END;//