{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

include:
  - .docker


docker-compose-project-dir:
  file.directory:
    - name: /etc/docker-compose/monitoring-proxy
    - user: root
    - group: root
    - mode: 0755
    - require:
      - sls: docker-compose


docker-compose-yml:
  file.managed:
    - name: /etc/docker-compose/monitoring-proxy/docker-compose.yml
    - source: salt://opg-docker-monitoring/templates/compose-monitoring-proxy.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - sls: docker-compose


docker-compose-up:
  cmd.run:
    - name: docker-compose -p monitoringproxy up -d
    - cwd: /etc/docker-compose/monitoring-proxy
    - shell: /bin/bash
    - env:
      - HOME: /root
    - watch:
      - file: /etc/docker-compose/*
    - require:
      - file: docker-compose-yml


{% for service in salt['pillar.get']('monitoring:proxy') %}
{% if 'env' in pillar['monitoring']['proxy'][service]  %}

/etc/docker-compose/monitoring-proxy/{{service}}.env:
  file.managed:
    - source: salt://opg-docker-monitoring/templates/service.env
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        project: 'proxy'
        service: {{service}}
    - require:
      - sls: docker-compose
      - file: docker-compose-project-dir

{% endif %}
{% endfor %}

