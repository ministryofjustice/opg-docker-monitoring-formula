{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker


docker-compose-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-server
    - user: root
    - group: root
    - mode: 0755
    - require:
      - sls: docker-compose


docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-server/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-server.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose


docker-compose-up:
  cmd.run:
    - name: docker-compose -p monitoringserver up -d
    - cwd: /etc/docker-compose/monitoring-server
    - shell: /bin/bash
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/*
    - require:
      - file: docker-compose-yml


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
      - file: docker-compose-project-dir

{% endif %}
{% endfor %}
