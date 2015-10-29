{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker
  - .crontab


monitoring-server-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-server
    - user: root
    - group: root
    - mode: 0755
    - require:
      - sls: docker-compose


monitoring-server-docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-server.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose


monitoring-server-docker-adhoc-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose-adhoc.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-adhoc.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose


monitoring-server-init:
  file.managed:
    - name: /etc/init.d/docker-compose-monitoring-server
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-server-init.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - require:
      - sls: docker-compose


monitoring-server-docker-compose-up:
  cmd.run:
    - name: docker-compose -p monitoringserver up -d
    - cwd: /etc/docker-compose/monitoring-server
    - shell: /bin/bash
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/*
    - require:
      - file: monitoring-server-docker-compose-yml
      - file: grafana-data-dir
      - file: graphite-data-dir
      - file: elasticsearch-data-dir


grafana-data-dir:
  file.directory:
    - name: {{ monitoring.server.grafana.data_dir }}
    - mode: 0777
    - makedirs: True


graphite-data-dir:
  file.directory:
    - name: {{ monitoring.server.graphite.data_dir }}
    - mode: 0777
    - makedirs: True


elasticsearch-data-dir:
  file.directory:
    - name: {{ monitoring.server.elasticsearch.data_dir }}
    - mode: 0777
    - makedirs: True


docker-compose-monitoring-server:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init.d/docker-compose-monitoring-server


{% for service in salt['pillar.get']('monitoring:server') %}
{% if 'env' in pillar['monitoring']['server'][service]  %}

/etc/docker-compose/monitoring-server/{{service}}.env:
  file.managed:
    - source: salt://opg-docker-monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'server'
        service: {{service}}
    - require:
      - sls: docker-compose
      - file: monitoring-server-project-dir

{% endif %}
{% endfor %}

