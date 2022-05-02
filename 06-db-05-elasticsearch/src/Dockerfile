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