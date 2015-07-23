{######################################################
Remember to include all dependencies:

include:
  - nginx
  - logstash.beaver
  - docker

######################################################}

{% from "logstash/lib.sls" import logship with context %}


{% macro vhost_port(appslug, port, is_external, is_default) %}

/etc/nginx/conf.d/{{appslug}}.conf:
  file:
    - managed
    - source: salt://opg-docker-monitoring/templates/vhost-port.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        appslug: {{appslug}}
        server_name: '{{appslug}} ~{{appslug}}.*'
        port: {{port}}
        is_external: {{is_external}}
        is_default: {{is_default}}
    - watch_in:
      - service: nginx


{{ logship(appslug+'-access', '/var/log/nginx/'+appslug+'.access.json', 'nginx', ['nginx', appslug, 'access'], 'rawjson') }}
{{ logship(appslug+'-error', '/var/log/nginx/'+appslug+'.error.log', 'nginx', ['nginx', appslug, 'error'], 'json') }}


{% endmacro %}
