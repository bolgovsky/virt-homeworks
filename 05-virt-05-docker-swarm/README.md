# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global? 

Ответ: 
`replication` - настраиваемое распространение микросервиса на докер ноды ,

`global` - распространение микросервиса на ВСЕ ноды


- Какой алгоритм выбора лидера используется в Docker Swarm кластере?

Ответ: `RAFT`. Изначально, первая же нода в кластере докер становится лидером, но кластер  считается неконсистентным.
А при достижении консистентности(3 и более ноды менеджеры) происходит постоянное голосование за лидерство по алгоритму 
поддержания распределенного консенсуса или `The Raft Consensus Algorithm`. По-простому: голосование через 
случайные таймауты. 

По порядку глубины разъяснения статьи для объяснения:
1) http://thesecretlivesofdata.com/raft/ нагляднее некуда

2) https://raft.github.io/

3) https://habr.com/ru/company/redmadrobot/blog/318866/

- Что такое Overlay Network?

Ответ: сеть "поверх" сетей хоста, создается по-умолчанию в докер кластере для безопасного взаимодействия(обмена данными)
между контейнерами. По-умолчанию создается `ingress` -обрабатывает трафик управления и данных, связанный со службами 

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls

[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
k6atexgllko9sbsjenrvpsrho *   node01.netology.yc   Ready     Active         Leader           20.10.13
tvfe7umiabl5dawnxm8aovqx2     node02.netology.yc   Ready     Active         Reachable        20.10.13
zjy62ib4yrwcgduhuwphloazv     node03.netology.yc   Ready     Active         Reachable        20.10.13
8z64o78felxg8a4wfr1hrgfuh     node04.netology.yc   Ready     Active                          20.10.13
fmhc4pw1zalz6ybb9exfs6q7y     node05.netology.yc   Ready     Active                          20.10.13
yc7e3yq412mnd1qu5259dzgdm     node06.netology.yc   Ready     Active                          20.10.13
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
wrh11a52tgl2   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
tzbxn1avelw1   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
1gzfuoovmp0k   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
lxj066r113y6   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
s16ymp7bnz80   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
zjakk7hwlq4q   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
v5li4y7jr4ij   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
q7ftohl2okf8   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```

## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна.
см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/

```[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-Rd0ZO27+5fM2bWCg8eJOkymj5VOzR7c3Oj//8Fn0Hb0

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
Ответ: включает блокировку менеджеров кластера докер в целях безопасности.
Ключ TLS, используемый для шифрования связи между узлами swarm и ключ, используемый для шифрования и расшифровки 
журналов Raft на диске - хранится в памяти каждого менеджера Docker. 
Оба этих ключа  можно защитить, если стать владельцем этих ключей и требовать ручной разблокировки ваших менеджеров.
Таким обрахом после перезапуска Docker вначале придется разблокировать swarm сгенерированным ключом.
