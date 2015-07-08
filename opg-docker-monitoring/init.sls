{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker
  - .env

monitoring-docker-compose:
  file.managed:
    - name: /etc/docker-compose/monitoring.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose

docker-compose-up:
  cmd.run:
    - name: docker-compose -p opgmonitoring -f /etc/docker-compose/monitoring.yml up -d
    - shell: /bin/bash
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/*
    - require:
      - file: monitoring-docker-compose
      - file: grafana-data-dir
      - file: graphite-data-dir
      - file: elasticsearch-data-dir


# /data is typically an EBS volume that has been created and mounted via the bootstrap process

grafana-data-dir:
  file.directory:
    - name: {{ monitoring.grafana.data_dir }}
    - mode: 0777
    - makedirs: True

graphite-data-dir:
  file.directory:
    - name: {{ monitoring.graphite.data_dir }}
    - mode: 0777
    - makedirs: True

elasticsearch-data-dir:
  file.directory:
    - name: {{ monitoring.elasticsearch.data_dir }}
    - mode: 0777
    - makedirs: True

