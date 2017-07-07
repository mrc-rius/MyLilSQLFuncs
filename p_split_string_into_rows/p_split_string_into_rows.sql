CREATE PROCEDURE `p_split_string_into_rows`(
	IN enableDebug INT,
	IN tableToInsert VARCHAR(255),  
	IN fieldToInsert VARCHAR(255),  
    IN numberOcurrences INT,
    IN tableToSearch VARCHAR(255),  
	IN fieldOneToSearch VARCHAR(255),  
    IN fieldTwoToSearch VARCHAR(255),
	IN firstValueToSearch VARCHAR(255),
    IN secondValueToSearch VARCHAR(255)
)
BEGIN

	DECLARE iterations INT;
	DECLARE tableId INT;
    DECLARE tableData TEXT;
    DECLARE extracted_string TEXT;
    DECLARE firstValuePosition INT;
    DECLARE firstValueLength INT;
    DECLARE secondValuePosition INT;
    DECLARE secondValueLength INT;

    
    SET @firstValueLength = LENGTH(firstValueToSearch);
    SET @secondValueLength = LENGTH(secondValueToSearch);
	SET @iterations=0;
    SET @extracted_string=NULL;
    
    IF enableDebug=1 THEN
		TRUNCATE TABLE general.dwh_debug;
        SELECT f_dwh_debug('p_split_string_into_rows','debug table truncated' ,'TRUNCATE TABLE general.dwh_debug');
		SELECT f_dwh_debug('p_split_string_into_rows','firstValueToSearch' ,firstValueToSearch);
        SELECT f_dwh_debug('p_split_string_into_rows','secondValueToSearch' ,secondValueToSearch);
        SELECT f_dwh_debug('p_split_string_into_rows','firstValueLength' ,@firstValueLength);
        SELECT f_dwh_debug('p_split_string_into_rows','secondValueLength' ,@secondValueLength);
	END IF;
    
    string_extraction: LOOP
		
        SET @sqlSelect = CONCAT ('SELECT ',fieldOneToSearch,',',fieldTwoToSearch,' INTO @tableId,@tableData FROM ',tableToSearch);
		PREPARE stmt FROM @sqlSelect;
		EXECUTE stmt;
		IF enableDebug=1 THEN
			SELECT f_dwh_debug('p_split_string_into_rows','INSIDE LOOP' ,'YES');
            SELECT f_dwh_debug('p_split_string_into_rows','select statement' ,@sqlSelect);
            SELECT f_dwh_debug('p_split_string_into_rows','tableData' ,@tableData);
		END IF;
        
        
		SET @firstValuePosition = LOCATE(firstValueToSearch,@tableData);
        SET @secondValuePosition = LOCATE(secondValueToSearch,@tableData); 
        
        SET @sqlSelect = 'SELECT SUBSTRING(@tableData,@firstValuePosition,@secondValuePosition-@firstValuePosition+@secondValueLength) INTO @extracted_string';
        PREPARE stmt FROM @sqlSelect;
		EXECUTE stmt;
        IF enableDebug=1 THEN
				SELECT f_dwh_debug('p_split_string_into_rows','select substring statement' ,@sqlSelect);
                SELECT f_dwh_debug('p_split_string_into_rows','extracted_string' ,@extracted_string);
		END IF;
		
        
        IF enableDebug=1 THEN
			SELECT f_dwh_debug('p_split_string_into_rows','firstValuePosition' ,@firstValuePosition);
            SELECT f_dwh_debug('p_split_string_into_rows','secondValuePosition' ,@secondValuePosition);
            SELECT f_dwh_debug('p_split_string_into_rows','extracted_string' ,@extracted_string);
            SELECT f_dwh_debug('p_split_string_into_rows','tableToInsert' ,tableToInsert);
            SELECT f_dwh_debug('p_split_string_into_rows','fieldToInsert' ,fieldToInsert);
		END IF;
        
        SET @sqlInsert = CONCAT ('INSERT INTO ',tableToInsert,' (',fieldToInsert,') VALUES (@extracted_string)');
        IF enableDebug=1 THEN
				SELECT f_dwh_debug('p_split_string_into_rows','insert statement' ,@sqlInsert);
		END IF;
		PREPARE stmt FROM @sqlInsert;
		EXECUTE stmt;
        
        
        SET @SqlUpdate = CONCAT ('UPDATE ',tableToSearch,' SET ',fieldTwoToSearch,'=SUBSTRING(@tableData,@secondValuePosition) WHERE ',fieldOneToSearch,'=@tableId');
		IF enableDebug=1 THEN
				SELECT f_dwh_debug('p_split_string_into_rows','update statement' ,@SqlUpdate);
		END IF;
        PREPARE stmt FROM @SqlUpdate;
		EXECUTE stmt;
        
        set @iterations=@iterations+1;
        
        IF enableDebug=1 THEN
			SELECT f_dwh_debug('p_split_string_into_rows','numberOcurrences' ,numberOcurrences);
            SELECT f_dwh_debug('p_split_string_into_rows','iterations' ,@iterations);
		END IF;
        
        IF @iterations=numberOcurrences THEN
            SET @SqlDelete = CONCAT ('DELETE FROM ',tableToSearch,' WHERE ',fieldOneToSearch,'=@tableId');
            IF enableDebug=1 THEN
				SELECT f_dwh_debug('p_split_string_into_rows','delete statement' ,@SqlDelete);
			END IF;
			PREPARE stmt FROM @SqlDelete;
			EXECUTE stmt;
			LEAVE string_extraction;
        END IF;
    END LOOP string_extraction;
	

END