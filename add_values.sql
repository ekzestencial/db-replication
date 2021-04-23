
drop procedure if exists dorepeat;

DELIMITER //
CREATE PROCEDURE dorepeat(p1 INT)
BEGIN
	SET @x = 0;
	SET @testName = 'Test';
	SET @currentName = @testName;
	
   WHILE @X < p1 DO
		SET @x = @x + 1;
		SET @currentName = CONCAT(@testName,@x);

		INSERT into Authors
		(FirstName, SecondName, Books_Count)
		SELECT @currentName, @currentName, @x;

  	END WHILE;    

END//
DELIMITER ;

call dorepeat(1000);

/*
DELETE
FROM Authors
WHERE Id > 6;
*/