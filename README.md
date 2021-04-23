### Build:
```
docker-compose build

docker-compose up -d
```

### Setup master

After setup is done, master state is:

```
mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      866 | db1          |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

There is one table Authors.
```
mysql> select * from Authors;
+----+-----------+------------+-------------+
| Id | FirstName | SecondName | Books_Count |
+----+-----------+------------+-------------+
|  1 | Arthur    | Clarke     |          21 |
|  2 | Richard   | Clarke     |          10 |
|  3 | Susanna   | Clarke     |           2 |
|  4 | Arthur    | Doyle      |          33 |
+----+-----------+------------+-------------+
4 rows in set (0.00 sec)
```

### Setup slave s1

mysql> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.01 sec)

mysql> SHOW SLAVE STATUS;
...  Read_Master_Log_Pos | Relay_Log_File         | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running...
...                  869 | mysql-relay-bin.000002 |          1084 | mysql-bin.000003      | Yes              | Yes
```

On Master:
```
mysql> INSERT into Authors (FirstName, SecondName, Books_Count) SELECT 'Jack', 'London', 50 UNION ALL SELECT 'Isaac', 'Asimov', 70;
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0
```

On slave s1:
```
mysql> select * from Authors;
+----+-----------+------------+-------------+
| Id | FirstName | SecondName | Books_Count |
+----+-----------+------------+-------------+
|  1 | Arthur    | Clarke     |          21 |
|  2 | Richard   | Clarke     |          10 |
|  3 | Susanna   | Clarke     |           2 |
|  4 | Arthur    | Doyle      |          33 |
|  5 | Jack      | London     |          50 |
|  6 | Isaac     | Asimov     |          70 |
+----+-----------+------------+-------------+
6 rows in set (0.00 sec)
```

### Setup slave s2

Full setup of slave s2 ![s2.log](https://github.com/GrigoriyYepick/L18-DB-replication/blob/main/setup_logs/logs_s2.txt) (similar to s1 setup).

### Add data and turn off s1

Logs for instering data on master and verifying updates delivered to slaves ![add_data.log](https://github.com/GrigoriyYepick/L18-DB-replication/blob/main/setup_logs/add_data.txt).
Data was inserted via ![add_values.sql](https://github.com/GrigoriyYepick/L18-DB-replication/blob/main/add_values.sql).

### Delete the last column on s2

Full ![log](https://github.com/GrigoriyYepick/L18-DB-replication/blob/main/setup_logs/drop_column_s1.txt).

After dropping column, slave was turned off by some reason. And it was not possible to start it:
```
mysql> SHOW SLAVE STATUS;
Empty set, 1 warning (0.00 sec)

mysql> START SLAVE;
ERROR 1200 (HY000): The server is not configured as slave; fix in config file or with CHANGE MASTER TO
```

After setting up master again and staring s2, it worked as expecred and received all updates:
```
mysql> CHANGE MASTER TO MASTER_HOST='10.5.0.4',MASTER_USER='slave',MASTER_PASSWORD='password',MASTER_LOG_FILE = 'mysql-bin.000003',MASTER_LOG_POS=1,GET_MASTER_PUBLIC_KEY=1;
Query OK, 0 rows affected, 9 warnings (0.04 sec)

mysql> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.01 sec)

master:
mysql> INSERT into Authors (FirstName, SecondName, Books_Count) SELECT 'Jack2', 'London2', 100 UNION ALL SELECT 'Isaac2', 'Asimov2', 140;
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT into Authors (FirstName, SecondName, Books_Count) SELECT 'Jack3', 'London3', 150 UNION ALL SELECT 'Isaac3', 'Asimov3', 210;
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

slave2:

mysql> select * from Authors;
+----+-----------+------------+
| Id | FirstName | SecondName |
+----+-----------+------------+
|  1 | Arthur    | Clarke     |
|  2 | Richard   | Clarke     |
|  3 | Susanna   | Clarke     |
|  4 | Arthur    | Doyle      |
|  5 | Jack      | London     |
|  6 | Isaac     | Asimov     |
|  8 | Jack2     | London2    |
|  9 | Isaac2    | Asimov2    |
| 11 | Jack3     | London3    |
| 12 | Isaac3    | Asimov3    |
+----+-----------+------------+
10 rows in set (0.00 sec)
```

### Delete medium column on s1

Full ![log](https://github.com/GrigoriyYepick/L18-DB-replication/blob/main/setup_logs/drop_column_s1.txt).

After deleting, slave s1 went into "Waiting for master to send event" state, didn't receive updates from master and it was not possible to resetup it:
```
mysql> SHOW SLAVE STATUS;

| Slave_IO_State                   | Master_Host | Master_User | Master_Port | Connect_Retry | Master_Log_File  | Read_Master_Log_Pos | Relay_Log_File         | Relay_Log_Pos | Relay_Master_Log_File | Slave_IO_Running | Slave_SQL_Running |
| Waiting for master to send event | 10.5.0.4    | slave       |        3306 |            60 | mysql-bin.000003 |                1531 | mysql-relay-bin.000002 |          1412 | mysql-bin.000003      | Yes              | No

mysql> CHANGE MASTER TO MASTER_HOST='10.5.0.4',MASTER_USER='slave',MASTER_PASSWORD='password',MASTER_LOG_FILE = 'mysql-bin.000003',MASTER_LOG_POS=1,GET_MASTER_PUBLIC_KEY=1;
ERROR 3021 (HY000): This operation cannot be performed with a running slave io thread; run STOP SLAVE IO_THREAD FOR CHANNEL '' first.
```




# db-replication
