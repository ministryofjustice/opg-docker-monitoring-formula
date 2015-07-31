{% from "opg-docker-monitoring/map.jinja" import monitoring with context %}

{% if monitoring.server.elasticsearch.curator.enabled %}

{% for index in monitoring['server']['elasticsearch']['curator']['indices'] %}
elasticsearch-curator-present-delete-{{index}}:
  cron.present:
    - name: "docker-compose -p opgcore -f /etc/docker-compose/monitoring-server/docker-compose-adhoc.yml run elasticcurator curator --host {{ monitoring['server']['elasticsearch']['curator']['indices'][index]['host'] }} delete indices {{ monitoring['server']['elasticsearch']['curator']['indices'][index]['options'] }}"
    - identifier: elasticsearch-curator-cron-delete-{{index}}
    - user: root
    - hour: '3'
    - minute: random
{% endfor %}

{% else %}

{% for index in monitoring['server']['elasticsearch']['curator']['indices'] %}
elasticsearch-curator-absent-delete-{{index}}:
  cron.absent:
    - identifier: elasticsearch-curator-cron-delete-{{index}}
    - user: root
{% endfor %}

{% endif %}
