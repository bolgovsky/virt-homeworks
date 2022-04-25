# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:

|  Question | Answer  |  
|---|---|
|- вывода списка БД   |  \l |  
|- подключения к БД   | \c test_db  |  
|- вывода списка таблиц   | \d  |  
|- вывода описания содержимого таблиц   | \d+  |
|- выхода из psql   | \q  |

```bash
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 my_db     | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(5 rows)


postgres=# \c test_db
You are now connected to database "test_db" as user "postgres"


test_db=# \d
               List of relations
 Schema |      Name      |   Type   |  Owner
--------+----------------+----------+----------
 public | clients        | table    | postgres
 public | clients_id_seq | sequence | postgres
 public | orders         | table    | postgres
 public | orders_id_seq  | sequence | postgres
(4 rows)


test_db=# \d+
                                           List of relations
 Schema |      Name      |   Type   |  Owner   | Persistence | Access method |    Size    | Description
--------+----------------+----------+----------+-------------+---------------+------------+-------------
 public | clients        | table    | postgres | permanent   | heap          | 16 kB      |
 public | clients_id_seq | sequence | postgres | permanent   |               | 8192 bytes |
 public | orders         | table    | postgres | permanent   | heap          | 16 kB      |
 public | orders_id_seq  | sequence | postgres | permanent   |               | 8192 bytes |
(4 rows)


postgres=# \q
root@bffae0acf927:/#
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

Ответ:
```bash 
postgres=# select attname,avg_width from pg_stats where tablename='orders' and avg_width=(select MAX(avg_width) from pg_stats where tablename='orders');
 attname | avg_width
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

[ШАРДИРОВАНИЕ](https://habr.com/ru/company/oleg-bunin/blog/433370/)

- Vertical partitioning — поколоночно. 

- Horizontal partitioning — режем построчно, может быть, внутри сервера.

`Sharding (~=, \in ...) Horizontal Partitioning == типично`

Ответ:
```bash 
postgres=# CREATE TABLE public.orders_1 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);
CREATE TABLE
postgres=# CREATE TABLE public.orders_2 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);
CREATE TABLE

postgres=# insert into orders_1 select * from orders where price>499;
INSERT 0 3

postgres=# insert into orders_2 select * from orders where price<=499;
INSERT 0 5

postgres=# select * from orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  2 | My little database   |   500
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
(8 rows)

postgres=# select * from orders_1;
 id |        title         | price
----+----------------------+-------
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(11 rows)

postgres=# select * from orders_2;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

[ПРИМЕРЫ АВТОМАТИЗАЦИИ РАЗДЕЛЕНИЯ](https://pgdash.io/blog/postgres-11-sharding.html)

[ОФ.ДОКУМЕНТАЦИЯ](https://postgrespro.ru/docs/postgresql/10/ddl-partitioning)

Ответ: ДА, есть встроенные механизмы `разделения`
```bash 
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);

CREATE TABLE public.orders_1 
    PARTITION OF orders
    FOR VALUES FROM ('500') TO (MAXVALUE);
    
CREATE TABLE public.orders_2 
    PARTITION OF orders
    FOR VALUES FROM ('0') TO ('500');
```

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Ответ:

```BASH
root@bffae0acf927:/backup# pg_dumpall -U postgres >/backup/test_database.dump
...
--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Ответ: добавил бы параметр `UNIQUE` для столбца `title`

```bash
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
) PARTITION BY RANGE (price);
```
---

