CREATE PROCEDURE `p_number_ocurrences`(
	IN tableToSearch VARCHAR(255),  
	IN fieldToSearch VARCHAR(255),  
	IN valueToSearch VARCHAR(255),
    OUT numberOcurrences INT
)
BEGIN
    DECLARE tableData TEXT;
    DECLARE valuePosition INT;
    DECLARE valueLength INT;
    DECLARE numberOcurrences INT;
    
    SET @sqlSelect = CONCAT ('SELECT ',fieldToSearch,' INTO @tableData FROM ',tableToSearch);
    PREPARE stmt FROM @sqlSelect;
	EXECUTE stmt;
    
    SET valueLength = LENGTH(valueToSearch);
    /*LOOP*/
	 search: LOOP
	    SET valuePosition = LOCATE(valueToSearch,tableData);
	    IF valuePosition>0 THEN
	      SET numberOcurrences=numberOcurrences+1;
	    	SET tableData=SUBSTRING(tableData,valuePosition+valueLength);
	    END IF;
	    IF valuePosition=0 THEN
	    	LEAVE search;
	    END IF;
    
    END LOOP search;
    /*END LOOP*/
END