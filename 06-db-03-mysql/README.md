# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

**Ответ:**
```bash
PS C:\Users\Денис> docker run -it --name my-sql -v c:\mount\data\:/data -e MYSQL_ROOT_PASSWORD=***** -d mysql
c182bbf02764deb06f49010a44ff0f06923402a6942b4edc9dc756930f252af2

PS C:\Users\Денис> docker exec -it c182bbf02764 bash
root@c182bbf02764:/#

root@c182bbf02764:/# mysql -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.


mysql> status
--------------
...
Server version:         8.0.28 MySQL Community Server - GPL
...
--------------


mysql> select * from orders where price>300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"
  
**Ответ:**
```bash
mysql> create user 'test'@'localhost' identified with mysql_native_password by 'test-pass' 
with 
MAX_QUERIES_PER_HOUR 100 
PASSWORD EXPIRE INTERVAL 180 DAY 
FAILED_LOGIN_ATTEMPTS 3 
ATTRIBUTE '{"fname":"James","lname":"Pretty"}';
Query OK, 0 rows affected (0.01 sec)
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

**Ответ:**
```bash
mysql> grant select on test_db.orders to 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.01 sec)
```

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

**Ответ:**
```bash
mysql> select * from  INFORMATION_SCHEMA.USER_ATTRIBUTES where user='test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

**Ответ:**
```bash
mysql> set profiling=1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql>  show table status from test_db like 'orders'\G;
*************************** 1. row ***************************
           Name: orders
         Engine: InnoDB
   ...
1 row in set (0.01 sec)

mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> show profiles;
+----------+------------+----------------------------------------------+
| Query_ID | Duration   | Query                                        |
+----------+------------+----------------------------------------------+

|       28 | 0.02585950 | ALTER TABLE orders ENGINE = MyISAM           |
|       30 | 0.02728775 | ALTER TABLE orders ENGINE = InnoDB           |
+----------+------------+----------------------------------------------+
15 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных (#1)
- Нужна компрессия таблиц для экономии места на диске (#2) 
- Размер буффера с незакомиченными транзакциями 1 Мб (#3)
- Буффер кеширования 30% от ОЗУ (#4)
- Размер файла логов операций 100 Мб (#5)

Приведите в ответе измененный файл `my.cnf`.

**Ответ:**
```bash
#...
[mysql]
# InnoDB variables

#1
innodb_flush_method = O_DSYNC

#2
innodb_file_per_table = 1

#3
innodb_log_buffer_size = 1MB

#4
#find 30% physical RAM
#root@c182bbf02764:/etc/mysql/conf.d# grep MemTotal /proc/meminfo | awk '{print $2 / 1024/100*30}'
#592.589
innodb_buffer_pool_size=593MB;

#5
innodb_log_file_size=100MB;
```
---

