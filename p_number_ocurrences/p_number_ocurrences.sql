CREATE PROCEDURE `p_number_ocurrences`(
    IN enableDebug INT,
	IN tableToSearch VARCHAR(255),  
	IN fieldToSearch VARCHAR(255),  
	IN valueToSearch VARCHAR(255),
    OUT numberOcurrences INT
)
BEGIN
    DECLARE tableData TEXT;
    DECLARE valuePosition INT;
    DECLARE valueLength INT;
    IF enableDebug=1 THEN
		TRUNCATE TABLE general.dwh_debug;
        SELECT f_dwh_debug('p_number_ocurrences','debug table truncated' ,'TRUNCATE TABLE general.dwh_debug');
	END IF;
		SET numberOcurrences=0;
		SET @sqlSelect = CONCAT ('SELECT ',fieldToSearch,' INTO @tableData FROM ',tableToSearch);
		PREPARE stmt FROM @sqlSelect;
		EXECUTE stmt;
		
		SET valueLength = LENGTH(valueToSearch);
        /*debug block*/
        IF enableDebug=1 THEN
			SELECT f_dwh_debug('p_number_ocurrences','sql statement' ,@sqlSelect);
			SELECT f_dwh_debug('p_number_ocurrences','tableToSearch' ,tableToSearch);
            SELECT f_dwh_debug('p_number_ocurrences','fieldToSearch' ,fieldToSearch);
			SELECT f_dwh_debug('p_number_ocurrences','valueToSearch' ,valueToSearch);
			SELECT f_dwh_debug('p_number_ocurrences','valueLength' ,valueLength);
            SELECT f_dwh_debug('p_number_ocurrences','numberOcurrences' ,numberOcurrences);
            SELECT f_dwh_debug('p_number_ocurrences','tableData' ,@tableData);
        END IF;
		/*LOOP*/
		 search: LOOP
			SET @valuePosition = LOCATE(valueToSearch,@tableData);
            /*debug block*/
            IF enableDebug=1 THEN
				SELECT f_dwh_debug('p_number_ocurrences','INSIDE LOOP' ,'YES');
                SELECT f_dwh_debug('p_number_ocurrences','valuePosition' ,@valuePosition);
                SELECT f_dwh_debug('p_number_ocurrences','tableData' ,@tableData);
			END IF;
			IF @valuePosition>0 THEN
			  SET numberOcurrences=ifnull(numberOcurrences,0)+1;
				SET @tableData=SUBSTRING(@tableData,@valuePosition+valueLength);
				/*debug block*/
				IF enableDebug=1 THEN
					SELECT f_dwh_debug('p_number_ocurrences','VALUE FIND' ,'YES');
					SELECT f_dwh_debug('p_number_ocurrences','numberOcurrences' ,numberOcurrences);
                    SELECT f_dwh_debug('p_number_ocurrences','tableData' ,@tableData);
				END IF;
			END IF;
			IF @valuePosition=0 THEN
				IF enableDebug=1 THEN
					SELECT f_dwh_debug('p_number_ocurrences','VALUE FIND' ,'NO');
				END IF;
				LEAVE search;
			END IF;
		
		END LOOP search;
        IF enableDebug=1 THEN
			SELECT f_dwh_debug('p_number_ocurrences','INSIDE LOOP' ,'NO');
        END IF;
		/*END LOOP*/
END