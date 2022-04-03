# Домашнее задание к занятию "6.2. SQL"



## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.


Ответ: 
```
PS C:\Users\Денис> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
PS C:\Users\Денис> docker run -it --name psql -v c:\mount\backup\:/backup -v c:\mount\data:/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=my_db -d postgres
bffae0acf92765057775642352a418603da743cf0944873a588b1aa8bca8b1c6
PS C:\Users\Денис> docker ps -a
CONTAINER ID   IMAGE      COMMAND                  CREATED         STATUS         PORTS      NAMES
bffae0acf927   postgres   "docker-entrypoint.s…"   4 seconds ago   Up 2 seconds   5432/tcp   psql
```
p.s.: docker - run postgresql -> must set all -e ENVIROMENT in UPPERCASE!!!!!!!!!!!!!!!!!! 

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db

```bash
PS C:\Users\Денис> docker exec -it bffae0acf927 bash

root@bffae0acf927:/# psql -U postgres
postgres=#
postgres=# create database test_db;
CREATE DATABASE


postgres=# create user "test-admin-user";
CREATE ROLE

```

- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

```bash 
test_db=# create table orders (id serial primary key , product text, cost int);
CREATE TABLE
test_db=# create table clients (id serial primary key, fullname text , country text, order_id int references orders(id));
CREATE TABLE

test_db=# create index idx_client_country on clients(country);
CREATE INDEX
```

- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db

```bash 
postgres=# grant all privileges on database test_db to "test-admin-user";
GRANT
postgres=# grant all privileges on all tables in schema public to "test-admin-user";
GRANT
```

- создайте пользователя test-simple-user  

```bash 
 postgres=# create user "test-simple-user";
CREATE ROLE
```

- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

```bash
postgres=# grant select,insert,update,delete on all tables in schema public to "test-simple-user";
GRANT 
```


Приведите:
- итоговый список БД после выполнения пунктов выше,

```bash 
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 my_db     | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(5 rows)
```

- описание таблиц (describe)

```bash 
test_db=# \d+ clients
                                                        Table "public.clients"
  Column  |  Type   | Collation | Nullable |               Default               | Storage  | Compression | Stats target | Description
----------+---------+-----------+----------+-------------------------------------+----------+-------------+--------------+-------------
 id       | integer |           | not null | nextval('clients_id_seq'::regclass) | plain    |             |              |
 fullname | text    |           |          |                                     | extended |             |              |
 country  | text    |           |          |                                     | extended |             |              |
 order_id | integer |           |          |                                     | plain    |             |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
Access method: heap



test_db=# \d+ orders
                                                        Table "public.orders"
 Column  |  Type   | Collation | Nullable |              Default               | Storage  | Compression | Stats target | Description
---------+---------+-----------+----------+------------------------------------+----------+-------------+--------------+-------------
 id      | integer |           | not null | nextval('orders_id_seq'::regclass) | plain    |             |              |
 product | text    |           |          |                                    | extended |             |              |
 cost    | integer |           |          |                                    | plain    |             |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
Access method: heap
```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

```bash 
test_db=# SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_name='orders'
;
     grantee      | privilege_type
------------------+----------------
 postgres         | INSERT
 postgres         | SELECT
 postgres         | UPDATE
 postgres         | DELETE
 postgres         | TRUNCATE
 postgres         | REFERENCES
 postgres         | TRIGGER
 test-simple-user | INSERT
 test-simple-user | SELECT
 test-simple-user | UPDATE
 test-simple-user | DELETE
 test-admin-user  | INSERT
 test-admin-user  | SELECT
 test-admin-user  | UPDATE
 test-admin-user  | DELETE
 test-admin-user  | TRUNCATE
 test-admin-user  | REFERENCES
 test-admin-user  | TRIGGER
(18 rows)
```  

- список пользователей с правами над таблицами test_db

```bash 

test_db=# \z orders
                                      Access privileges
 Schema |  Name  | Type  |         Access privileges          | Column privileges | Policies
--------+--------+-------+------------------------------------+-------------------+----------
 public | orders | table | postgres=arwdDxt/postgres         +|                   |
        |        |       | "test-simple-user"=arwd/postgres  +|                   |
        |        |       | "test-admin-user"=arwdDxt/postgres |                   |
(1 row)

test_db=# \z clients
                                      Access privileges
 Schema |  Name   | Type  |         Access privileges          | Column privileges | Policies
--------+---------+-------+------------------------------------+-------------------+----------
 public | clients | table | postgres=arwdDxt/postgres         +|                   |
        |         |       | "test-simple-user"=arwd/postgres  +|                   |
        |         |       | "test-admin-user"=arwdDxt/postgres |                   |
(1 row)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.


```bash 
test_db=# insert into orders (product,cost) values ('Шоколад',10);
INSERT 0 1
test_db=# insert into orders (product,cost) values ('Принтер',3000);
INSERT 0 1
test_db=# insert into orders (product,cost) values ('Книга',500);
INSERT 0 1
test_db=# insert into orders (product,cost) values ('Монитор',7000);
INSERT 0 1
test_db=# insert into orders (product,cost) values ('Гитара',4000);



test_db=# insert into clients (fullname,country) values ('Иванов Иван Иванович','USA');
INSERT 0 1
test_db=# insert into clients (fullname,country) values ('Петров Петр Петрович','Canada');
INSERT 0 1
test_db=# insert into clients (fullname,country) values ('Иоганн Себастьян Бах','Japan');
INSERT 0 1
test_db=# insert into clients (fullname,country) values ('Ронни Джеймс Дио','Russia');
INSERT 0 1
test_db=# insert into clients (fullname,country) values ('Ritchie Blackmore','Russia');
INSERT 0 1


test_db=# select * from orders;
 id | product | cost
----+---------+------
  1 | Шоколад |   10
  2 | Принтер | 3000
  3 | Книга   |  500
  4 | Монитор | 7000
  5 | Гитара  | 4000
(5 rows)

test_db=# select * from clients;
 id |       fullname       | country | order_id
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |         
  2 | Петров Петр Петрович | Canada  |         
  3 | Иоганн Себастьян Бах | Japan   |  
  4 | Ронни Джеймс Дио     | Russia  |
  5 | Ritchie Blackmore    | Russia  |       
(5 rows)


test_db=# select count(*) from clients;
 count
-------
     5
(1 row)

test_db=# select count(*) from orders;
 count
-------
     5
(1 row)

```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.


```bash 
test_db=# update clients set order_id = (select id from orders where product='Книга') where fullname='Иванов Иван Иванович';
UPDATE 1
test_db=# update clients set order_id = (select id from orders where product='Монитор') where fullname='Петров Петр Петрович';
UPDATE 1
test_db=# update clients set order_id = (select id from orders where product='Гитара') where fullname='Иоганн Себастьян Бах';
UPDATE 1

test_db=# select * from clients where order_id is not null;
 id |       fullname       | country | order_id
----+----------------------+---------+----------
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(3 rows)

```


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
  
```bash 
test_db=# explain select * from clients where order_id is not null;
                       QUERY PLAN
--------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1.05 rows=5 width=72)
   Filter: (order_id IS NOT NULL)
(2 rows)
```

 используется `Seq Scan` — последовательное, блок за блоком, чтение данных таблицы clients.

 `cost`:
 Первое значение 0.00 — затраты на получение первой строки.
 Второе — 18334.00 — затраты на получение всех строк.

 `rows` — приблизительное количество возвращаемых строк при выполнении операции Seq Scan. Это значение возвращает планировщик. В моём случае оно совпадает с реальным количеством строк в таблице.

 `width` — средний размер одной строки в байтах.


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```bash
root@bffae0acf927:/# pg_dump -U postgres test_db > /backup/test_db.dump
root@bffae0acf927:/# cd backup
root@bffae0acf927:/backup# ls -lha
total 8.0K
drwxrwxrwx 1 root root 4.0K Apr  3 23:14 .
drwxr-xr-x 1 root root 4.0K Apr  3 16:30 ..
-rw-r--r-- 1 root root 3.8K Apr  3 23:14 test_db.dump
```


Остановите контейнер с PostgreSQL (но не удаляйте volumes).

```bash
docker stop bffae0acf927
bffae0acf927
PS C:\Users\Денис> docker ps -a
CONTAINER ID   IMAGE      COMMAND                  CREATED       STATUS                     PORTS     NAMES
bffae0acf927   postgres   "docker-entrypoint.s…"   7 hours ago   Exited (0) 3 seconds ago             psql
```

Поднимите новый пустой контейнер с PostgreSQL.

```bash
PS C:\Users\Денис> docker run -it --name restore_backup -v c:\mount\backup\:/backup -v c:\mount\data:/data -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=my_db -d postgres
ea76850fe40e90443a38d4d7ff232c25b0591daa7aa5560b61b53a4960aa5426  
PS C:\Users\Денис> docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED         STATUS         PORTS      NAMES
ea76850fe40e   postgres   "docker-entrypoint.s…"   4 seconds ago   Up 4 seconds   5432/tcp   restore_backup
```

Восстановите БД test_db в новом контейнере.

```bash
PS C:\Users\Денис> docker exec -it ea76850fe40e bash

root@ea76850fe40e:/# cd backup/
root@ea76850fe40e:/backup# ls -lha
total 8.0K
drwxrwxrwx 1 root root 4.0K Apr  3 23:14 .
drwxr-xr-x 1 root root 4.0K Apr  3 23:16 ..
-rw-r--r-- 1 root root 3.8K Apr  3 23:14 test_db.dump


root@ea76850fe40e:/backup# pg_restore -d test_db test_db.dump
pg_restore: error: input file appears to be a text format dump. Please use psql.



root@ea76850fe40e:/backup# psql -U postgres < /backup/test_db.dump
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
```

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

Результат:

```bash
root@ea76850fe40e:/backup# psql -U postgres
psql (14.2 (Debian 14.2-1.pgdg110+1))
Type "help" for help.

postgres=# \z
                                   Access privileges
 Schema |      Name      |   Type   | Access privileges | Column privileges | Policies
--------+----------------+----------+-------------------+-------------------+----------
 public | clients        | table    |                   |                   |
 public | clients_id_seq | sequence |                   |                   |
 public | orders         | table    |                   |                   |
 public | orders_id_seq  | sequence |                   |                   |
(4 rows)

postgres=# \d+ clients
                                                        Table "public.clients"
  Column  |  Type   | Collation | Nullable |               Default               | Storage  | Compression | Stats target | Description
----------+---------+-----------+----------+-------------------------------------+----------+-------------+--------------+-------------
 id       | integer |           | not null | nextval('clients_id_seq'::regclass) | plain    |             |              |
 fullname | text    |           |          |                                     | extended |             |              |
 country  | text    |           |          |                                     | extended |             |              |
 order_id | integer |           |          |                                     | plain    |             |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "idx_client_country" btree (country)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
Access method: heap




postgres=# select * from orders
postgres-# ;
 id | product | cost
----+---------+------
  1 | Шоколад |   10
  2 | Принтер | 3000
  3 | Книга   |  500
  4 | Монитор | 7000
  5 | Гитара  | 4000
(5 rows)

postgres=# select * from clients
;
 id |       fullname       | country | order_id
----+----------------------+---------+----------
  4 | Ронни Джеймс Дио     | Russia  |
  5 | Ritchie Blackmore    | Russia  |
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(5 rows)
```

---

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).
---
