
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

---

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

Ответ:  
[Репозиторий c nginx](https://hub.docker.com/repository/docker/bolgovsky/netology)


---

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

---

_"Докер контейнер - это процесс на хосте, который ограничен по ресурсам и правам. Это не виртуальная машина. 
Потому, все кейсы, которые предусматривают запуск процесса, который может писать логи в stdout/stderr, лучше чтобы не зависел от шелла, может коммуницировать по сети - для таких процессов подходит контейнеризация.
И напротив, если у нас есть приложение, которое демонизировано, пишет логи в файлы, не коммуницирует по сети, то для него не подойдет контейнеризация."_


Если, не так давно, особенно в изолированных сетях организаций, наблюдалась тенденция использования в лучшем случае виртуальных машин и физических серверов для решения задач (пусть даже высоконагруженных),
то в подавляющем большинстве теперь - это разработка и внедрение микросервисной архитектуры, IaaC со всеми вытекающими преимуществами.

Все ссылки добавлены исключительно для формирования личной базы знаний и не являются утверждением де факто)

(*) все варианты, связанные с использованием хранилищ, предполагается реализовывать через  docker volumes

Сценарий:

- Высоконагруженное монолитное java веб-приложение; 

Ответ: виртуальная машина (потери производительности можно нивелировать удобством обслуживания) или, на крайний случай, физический сервер. Единственный вариант использования,но тоже с оговорками, - разделение монолитного приложения на микросервисное, тогда использование Docker хотя бы будет понятной попыткой)

[Java и Docker: это должен знать каждый](https://habr.com/ru/company/ruvds/blog/324756/)

"JVM до сих пор не имеет средств, позволяющих определить, что она выполняется в контейнеризированной среде и учесть ограничения некоторых ресурсов, таких, как память и процессор. Поэтому нельзя позволять механизму JVM ergonomics самостоятельно задавать максимальный размер кучи."


- Nodejs веб-приложение;

Ответ: как правило, для таких приложений использование Docker контейнеров - вопрос времени. Т.е. наверняка упаковка веб-приложения nodejs будет лучшим решением. 

[Лучшие практики](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

- Мобильное приложение c версиями для Android и iOS;

Ответ: если для android есть вполне рабочие варианты использования Docker (https://habr.com/ru/company/ruvds/blog/324756/), то для iOS с оговорками, а точнее для тестов только (https://dev.to/ianito/how-to-emulate-ios-on-linux-with-docker-4gj3) .
Таким образом, если мы рассматриваем вариант единого, общего рабочего окружения, то это виртуальные машины, так как версий (android, iOS) самих систем множество. Но если нет- вполне можно использовать Docker+VM(iOS).

- Шина данных на базе Apache Kafka;

Ответ: думаю, что использовать Docker контейнеры в данном случае будет правильным направлением развития. 

[Spring Boot + Apache Kafka и SSL в Docker контейнере](https://habr.com/ru/post/505720/)

[Руководство по настройке Apache Kafka с помощью Docker](https://www.baeldung.com/ops/kafka-docker-setup)

Apache Kafka работает в связке с ZOOKEEPER и оба возможно использовать в микросервисной архитектуре с использованием контейнеров. Масштабирование и использовать IaaC сильно расширит возможности.
Но простом варианте использования вполне подойдет и виртуальная машина.

- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;

Ответ: ELK Stack предполагает использовать Docker контейнеры сам по себе, то есть микросервисную архитектуру. Таким образом , чем больше нод, тем больше выгоды использовать принципы IaaC, а в данном варианте - Docker. 
В данном случае даже использование виртуальных машин значительно усложнит жизнь инженерам внедрения и сопровождения, не говоря уже о физических серверах. 

[Централизованное логирование в Docker с применением ELK Stack](https://habr.com/ru/company/otus/blog/542144/)

- Мониторинг-стек на базе Prometheus и Grafana;

Ответ: Prometheus, Node Exporter и Grafana - этот стек отлично можно обернуть в контейнеры. Соответственно выгоднее всего будет использовать Docker, затем виртуальные машины, а затем уже физические серверы.

[Официальная страница grafana-docker](https://grafana.com/docs/grafana-cloud/quickstart/docker-compose-linux/)

[docker-compose быстро собрать систему мониторинга Prometheus + Grafana](https://russianblogs.com/article/8036920964/)

- MongoDB, как основное хранилище данных для java-приложения;

Ответ: ну, ничего лучше по производительности , чем локальные хранилища не придумали , поэтому,  в порядке убывания приоритета использования: физический сервер, виртуальная машина, docker контейнер.  
Лично я бы остановился на виртуальной машине Java+mongo.

- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Ответ:  использование docker контейнеров выглядит привлекательным. CI/CD вообще правильнее организовывать кодом. Локальный docker registry есть на официальном сайте (докер хаб ) и описан в документации.    
Возможно, в каких-то случаях (тестовых скорее всего) будет  иметь смысл запускать и на виртуальной машине, но на физическом сервере запускать данные средства избыточно и плохо в обслуживании.

[Docker CI: установка и настройка Gitlab](https://russianblogs.com/article/772161795/)
[Настройка локального хранилища Docker Registry](https://winitpro.ru/index.php/2021/03/03/nastrojka-lokalnogo-docker-registry/)


---

ПЛЮСОМ: [Итнересное про docker](https://habr.com/ru/post/467607/)

---

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

Ответ: 
```bash
sudo docker run -it -v /mnt/c/Users/Денис/PycharmProjects/virt-homeworks/05-virt-03-docker-usage/data:/data -d centos

sudo docker run -it -v /mnt/c/Users/Денис/PycharmProjects/virt-homeworks/05-virt-03-docker-usage/data:/data -d debian

docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
68ec9112f966   debian    "bash"    3 minutes ago   Up 3 minutes             dreamy_hopper
04f7542fe383   centos    "bash"    6 minutes ago   Up 6 minutes             brave_wilbur

docker exec -it 04f7542fe383 bash
[root@04f7542fe383 /]# ls
bin   dev  home  lib64       media  opt   root  sbin  sys  usr
data  etc  lib   lost+found  mnt    proc  run   srv   tmp  var
[root@04f7542fe383 /]# cd data
[root@04f7542fe383 data]# ls
[root@04f7542fe383 data]# touch from-centos.txt
[root@04f7542fe383 data]# vi from-centos.txt
[root@04f7542fe383 data]# cat from-centos.txt
cwijcwiojcowkcn[wkckwm
[root@04f7542fe383 data]# exit

docker exec -it 68ec9112f966fc1cb60fd1a0364e21064ecfc58fbe1dad1e2aca5d683e59a876 bash
root@68ec9112f966:/# ls
bin   data  etc   lib    media  opt   root  sbin  sys  usr
boot  dev   home  lib64  mnt    proc  run   srv   tmp  var
root@68ec9112f966:/# cd data
root@68ec9112f966:/data# ls
from-centos.txt
root@68ec9112f966:/data# cat from-centos.txt
cwijcwiojcowkcn[wkckwm
```

Видим, что и на хосте, в папке `c:\Users\Денис\PycharmProjects\virt-homeworks\05-virt-03-docker-usage\data\from-centos.txt `, появился файл `from-centos.txt` 
Создадим в этой папке файл `from-host.txt` с содержимым :
```
ddwedwedwedwe


```

```bash 
docker exec -it 68ec9112f966fc1cb60fd1a0364e21064ecfc58fbe1dad1e2aca5d683e59a876 bash
root@68ec9112f966:/# ls
bin   data  etc   lib    media  opt   root  sbin  sys  usr
boot  dev   home  lib64  mnt    proc  run   srv   tmp  var
root@68ec9112f966:/# cd data
root@68ec9112f966:/data# ls
from-centos.txt
root@68ec9112f966:/data# cat from-centos.txt
cwijcwiojcowkcn[wkckwm
root@68ec9112f966:/data# ls
from-centos.txt  from-host.txt
root@68ec9112f966:/data# cat from-host.txt
ddwedwedwedwe


root@68ec9112f966:/data# exit
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

```bash
denis@DenisPC:/mnt/c/Users/Денис/PycharmProjects/virt-homeworks/05-virt-03-docker-usage/src/build/ansible$ docker build -t bolgovsky/ansible:1.0.1 .
[+] Building 339.3s (9/9) FINISHED

docker images
REPOSITORY           TAG        IMAGE ID       CREATED              SIZE
bolgovsky/ansible    1.0.1      fc5cec7585a0   About a minute ago   230MB

docker login
Authenticating with existing credentials...
Login Succeeded

docker push bolgovsky/ansible:1.0.1
The push refers to repository [docker.io/bolgovsky/ansible]
5f70bf18a086: Pushed
1930808e898f: Pushed
2ce35802b8f0: Pushed
1a058d5342cc: Mounted from library/alpine
1.0.1: digest: sha256:a25ec3761c884b72ea5205093af59171d9ff32a0d3e572a245e0df52b5d25e36 size: 1153
```

Ответ:
[Репозиторий с ansible](https://hub.docker.com/repository/docker/bolgovsky/ansible)

---
