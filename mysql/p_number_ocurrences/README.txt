@Functionality is:
	This procedure returns the number of times that an specified string is find into another one.
	The difference with LOCATE default function is that this procedure search a value in a specified field of a specified table.

@Params are:
	IN tableToSearch VARCHAR(255) --> Table from where you select values  
	IN fieldToSearch VARCHAR(255), --> Table field that will be select.
	IN valueToSearch VARCHAR(255), --> Value to find in the return of the select query.
    	OUT numberOcurrences INT --> Number of time that 'valueToSearch' ins in the field 'fieldToSearch' of the table 'tableToSearch'