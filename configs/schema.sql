CREATE DATABASE IF NOT EXISTS db1;
GRANT ALL PRIVILEGES ON db1.* TO 'user1'@'%' ;
GRANT ALL PRIVILEGES ON mysql.* TO 'user1'@'%' ;
GRANT SUPER ON *.* TO 'user1'@'%' ;
GRANT FILE ON *.* TO 'user1'@'%';

CREATE TABLE Authors (
  Id INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(255) NOT NULL,
  SecondName VARCHAR(255) NOT NULL,
  Books_Count INT NOT NULL
) ENGINE=INNODB;

INSERT into Authors
(FirstName, SecondName, Books_Count)
SELECT 'Arthur', 'Clarke', 21
UNION ALL
SELECT 'Richard', 'Clarke', 10
UNION ALL
SELECT 'Susanna', 'Clarke', 2
UNION ALL
SELECT 'Arthur', 'Doyle', 33

