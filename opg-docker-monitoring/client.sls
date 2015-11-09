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
      - file: monitoring-client-project-dir


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


monitoring-client-docker-compose-pull:
  cmd.run:
    - name: docker-compose -p monitoringclient pull
    - cwd: /etc/docker-compose/monitoring-client
    - shell: /bin/bash
    - env:
      - HOME: /root
    - require:
      - file: monitoring-client-docker-compose-yml


docker-compose-monitoring-client:
  service.running:
    - enable: True
    - watch:
      - file: monitoring-client-init
      - file: monitoring-client-docker-compose-yml
    - require:
      - cmd: monitoring-client-docker-compose-pull
    - order: last


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
    - require_in:
      - service: docker-compose-monitoring-client
      - cmd: monitoring-client-docker-compose-pull
    - watch_in:
      - service: docker-compose-monitoring-client

{% endif %}
{% endfor %}

