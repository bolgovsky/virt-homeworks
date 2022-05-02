# Домашнее задание к занятию "6.5. Elasticsearch"

---

В данном файле приведены **только ответы** ! Т.е. можно искать по **Ответ:**

Для восстановления последовательности действий со всеми возникшими ошибками (из раздела "ПОДСКАЗКИ"- почти все) и их решениями см.
[step-by-step.txt]()

---

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [elasticsearch:7](https://hub.docker.com/_/elasticsearch) как базовый:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib` 
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста

**Ответ:**
```bash 
FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.3
LABEL maintainer="bolgovsky@mail.ru"

COPY --chown=elasticsearch:elasticsearch ./elasticsearch.yml /usr/share/elasticsearch/config/

RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/config/
RUN chown -R elasticsearch:elasticsearch /var/lib

RUN mkdir /usr/share/elasticsearch/snapshots
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots

CMD ["sysctl -w vm.max_map_count=262144"]

CMD ["elasticsearch"]

EXPOSE 9200
```
- ссылку на образ в репозитории dockerhub

**Ответ:** 
  [DockerHub.io bolgovsky/devops-elasticsearch tag 1.0.1](https://hub.docker.com/repository/docker/bolgovsky/devops-elasticsearch)

- ответ `elasticsearch` на запрос пути `/` в json виде

**Ответ:**
```bash
{
  "name" : "netology_test",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "SMEbRVHGSoC5WZMH-uhwjA",
  "version" : {
    "number" : "7.17.3",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "5ad023604c8d7416c9eb6c0eadb62b14e766caff",
    "build_date" : "2022-04-19T08:11:19.070913226Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения
- обратите внимание на настройки безопасности такие как `xpack.security.enabled` 
- если докер образ не запускается и падает с ошибкой 137 в этом случае может помочь настройка `-e ES_HEAP_SIZE`
- при настройке `path` возможно потребуется настройка прав доступа на директорию

Далее мы будем работать с данным экземпляром elasticsearch.

---

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

**Ответ:** 

```bash
root@3f38ce04b876:/usr/share/elasticsearch# curl -X GET "localhost:9200/_cat/indices/ind-*"
green  open ind-1 Ksvr_fuETHiTq1-tnIN4Og 1 0 0 0 226b 226b
yellow open ind-3 dGzG626qSRGT0pf7aSUEAA 4 2 0 0 904b 904b
yellow open ind-2 IxDxbRLLTUGXIy75kkmWaw 2 1 0 0 452b 452b
```

Получите состояние кластера `elasticsearch`, используя API.

**Ответ:** 

```bash 
root@3f38ce04b876:/usr/share/elasticsearch# curl -X GET "http://localhost:9200/_cluster/health"
{"cluster_name":"docker-cluster","status":"yellow","timed_out":false,"number_of_nodes":1,"number_of_data_nodes":1,"active_primary_shards":12,"active_shards":12,"relocating_shards":0,"initializing_shards":0,"unassigned_shards":11,"delayed_unassigned_shards":0,"number_of_pending_tasks":0,"number_of_in_flight_fetch":0,"task_max_waiting_in_queue_millis":0,"active_shards_percent_as_number":52.17391304347826}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

**Ответ:** 

| Проблема | Причина | 
|-----|-------------------|
| _КЛАСТЕР(yellow)_ | - все primary шарды в состоянии assigned. Часть secondary - шард в состоянии unassigned.|
| _ИНДЕКС(yellow)_ | - по-факту для 'ind-2' и 'ind-3' мы создали большее количество реплик и шард, чем есть на самом деле.|

Удалите все индексы.
```bash 
root@3f38ce04b876:/usr/share/elasticsearch# curl -X DELETE "localhost:9200/ind-*"
{"acknowledged":true}
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

**Ответ:** 
```bash 
root@0fc930d6feef:/usr/share/elasticsearch# curl -X PUT "localhost:9200/_snapshot/netology_backup" -H 'Content-Type: application/json' -d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/usr/share/elasticsearch/snapshots"
>   }
> }
> '
{"acknowledged":true}
```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

**Ответ:** 
```bash
root@0fc930d6feef:/usr/share/elasticsearch/snapshots# curl -X GET "localhost:9200/_cat/indices/*"
green open test                      wrq3f38chfiUQ2Ce04b876  1 0   0   0    226b    226b
green open .geoip_databases            pre6FFQBRPuOGvtT8zULeQ 1 0  40   0  37.7mb  37.7mb
green open .monitoring-es-7-2022.05.02 cpuLhfiUQ2CtnK2ReZEnVA 1 0 604 323 922.8kb 922.8kb
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.



**Приведите в ответе** список файлов в директории со `snapshot`ами.

**Ответ:** 
```bash
root@0fc930d6feef:/usr/share/elasticsearch/snapshots# ls -lha
total 60K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K May  2 12:48 .
drwxrwxr-x 1 root          root          4.0K May  2 12:34 ..
-rw-rw-r-- 1 elasticsearch root          1.7K May  2 12:48 index-0
-rw-rw-r-- 1 elasticsearch root             8 May  2 12:48 index.latest
drwxrwxr-x 7 elasticsearch root          4.0K May  2 12:48 indices
-rw-rw-r-- 1 elasticsearch root           29K May  2 12:48 meta-L6vJE4L3TCShaQ1p7yWZxQ.dat
-rw-rw-r-- 1 elasticsearch root           789 May  2 12:48 snap-L6vJE4L3TCShaQ1p7yWZxQ.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

**Ответ:** 
```bash
root@0fc930d6feef:/usr/share/elasticsearch/snapshots# curl -X GET "localhost:9200/_cat/indices/*"
green open test-2                      pKt2ovpiQQKGU7vrxakeHg 1 0   0   0    226b    226b
green open .geoip_databases            pre6FFQBRPuOGvtT8zULeQ 1 0  40   0  37.7mb  37.7mb
green open .monitoring-es-7-2022.05.02 cpuLhfiUQ2CtnK2ReZEnVA 1 0 604 323 922.8kb 922.8kb
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

**Ответ:** 
```bash
root@0fc930d6feef:/usr/share/elasticsearch/snapshots# curl -X POST  "localhost:9200/.*/_close?pretty"
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "indices" : {
    ".ds-ilm-history-5-2022.05.02-000001" : {
      "closed" : true
    },
    ".ds-.logs-deprecation.elasticsearch-default-2022.05.02-000001" : {
      "closed" : true
    },
    ".monitoring-es-7-2022.05.02" : {
      "closed" : true
    }
  }
}


# restore
root@0fc930d6feef:/usr/share/elasticsearch/snapshots# curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot_2022.05.02/_restore?pretty"
{
  "accepted" : true
}

root@0fc930d6feef:/usr/share/elasticsearch/snapshots# curl -X GET "localhost:9200/_cat/indices/*"
green open test-2                      pKt2ovpiQQKGU7vrxakeHg 1 0   0   0    226b    226b
green open .geoip_databases            34EnSqi9SFejlwd-YU9cfg 1 0  40   0  37.7mb  37.7mb
green open test                        ZG5SID8jRJ6HKVNcgjm4nQ 1 0   0   0    226b    226b
green open .monitoring-es-7-2022.05.02 cpuLhfiUQ2CtnK2ReZEnVA 1 0 604 323 572.2kb 572.2kb
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---
