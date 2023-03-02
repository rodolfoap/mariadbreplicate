# MariaDB Database Replication

This is a typical simple case of master/slave replication. See https://mariadb.com/kb/en/setting-up-replication/

## TL;DR: Usage

The full procedure can be triggered as this:
```
docker-compose up -d # will take about 15 seconds
./setup_master
./setup_slave
./setup_db
```

## Detailed process

### 1. MASTER configuration file

To start, configure the master `/etc/mysql/conf.d/mariadb.cnf` file:
```
[client]

[mariadb]
# Not strictly necessary, but recommended
log-bin

# Must be unique
server_id=1
```

### 2. SLAVE configuration file

Same thing for the slave `/etc/mysql/conf.d/mariadb.cnf` file:
```
[client]

[mariadb]

# Not strictly necessary, but recommended
log-bin

# Must be unique
server_id=2
```

### 3. MASTER setup

Launch the servers, and setup master:
```
CREATE USER 'replication_user'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
SHOW MASTER STATUS \G;
```

The last command outputs:
```
*************************** 1. row ***************************
            File: mysqld-bin.000002
        Position: 684
    Binlog_Do_DB:
Binlog_Ignore_DB:
```
Remark the ***File*** and the ***Position*** values.

### 4. SLAVE setup

Now, setup the slave using the ***File*** and the ***Position*** values:
```
CHANGE MASTER TO
  MASTER_HOST='master',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='password',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='mysqld-bin.000002',
  MASTER_LOG_POS=684,
  MASTER_CONNECT_RETRY=10;

START SLAVE;
```

### 5. Test Replication

Now, let's create a database and populate it on the **master**, and query it on the **slave**:
```
CREATE DATABASE test;
USE test;
CREATE TABLE clients (id INT, name VARCHAR(64), email VARCHAR(64));
INSERT INTO  clients (id, name, email) VALUES (01, "Martin Caraffe", "martin_caraffe@company.com");
INSERT INTO  clients (id, name, email) VALUES (02, "Josef Burratto", "josef_burratto@company.com");

SELECT *, "MASTER" as HOST FROM clients;
```
... which gives:
```
--------------
SELECT *, "MASTER" as HOST FROM clients
--------------
id	name	email	HOST
1	Martin Caraffe	martin_caraffe@company.com	MASTER
2	Josef Burratto	josef_burratto@company.com	MASTER
```

The changes must be instantly available on the slave:
```
USE test;
SELECT *, "SLAVE" as HOST FROM clients;
```
...which gives:
```
--------------
SELECT *, "SLAVE" as HOST FROM clients
--------------
id	name	email	HOST
1	Martin Caraffe	martin_caraffe@company.com	SLAVE
2	Josef Burratto	josef_burratto@company.com	SLAVE
```

