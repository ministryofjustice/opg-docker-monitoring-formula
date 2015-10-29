{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker


monitoring-client-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-client
    - user: root
    - group: root
    - mode: 0755
    - require:
      - sls: docker-compose


monitoring-client-docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-client/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-client.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose


monitoring-client-init:
  file.managed:
    - name: /etc/init.d/docker-compose-monitoring-client
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-client-init.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - require:
      - sls: docker-compose


docker-compose-monitoring-client:
  service.running:
    - enable: True
    - watch:
      - file: /etc/init.d/docker-compose-monitoring-client


monitoring-client-docker-compose-up:
  cmd.run:
    - name: docker-compose -p monitoringclient up -d
    - cwd: /etc/docker-compose/monitoring-client
    - shell: /bin/bash
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/*
    - require:
      - file: monitoring-client-docker-compose-yml


{% for service in salt['pillar.get']('monitoring:client') %}
{% if 'env' in pillar['monitoring']['client'][service]  %}

/etc/docker-compose/monitoring-client/{{service}}.env:
  file.managed:
    - source: salt://opg-docker-monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'client'
        service: {{service}}
    - require:
      - sls: docker-compose
      - file: monitoring-client-project-dir

{% endif %}
{% endfor %}

