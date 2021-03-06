---
{%- if grains.os_family in ('RedHat',) %}
  {%- set group = 'nginx' %}
{%- else %}
  {%- set group = 'www-data' %}
{%- endif %}

### ARVADOS
arvados:
  config:
    group: {{ group }}

### NGINX
nginx:
  ### SERVER
  server:
    config:

      ### STREAMS
      http:
        upstream workbench_upstream:
          - server: 'workbench.internal:9000 fail_timeout=10s'

  ### SITES
  servers:
    managed:
      ### DEFAULT
      arvados_workbench_default.conf:
        enabled: true
        overwrite: true
        config:
          - server:
            - server_name: workbench.fixme.example.net
            - listen:
              - 80
            - location /.well-known:
              - root: /var/www
            - location /:
              - return: '301 https://$host$request_uri'

      arvados_workbench_ssl.conf:
        enabled: true
        overwrite: true
        config:
          - server:
            - server_name: workbench.fixme.example.net
            - listen:
              - 443 http2 ssl
            - index: index.html index.htm
            - location /:
              - proxy_pass: 'http://workbench_upstream'
              - proxy_read_timeout: 300
              - proxy_connect_timeout: 90
              - proxy_redirect: 'off'
              - proxy_set_header: X-Forwarded-Proto https
              - proxy_set_header: 'Host $http_host'
              - proxy_set_header: 'X-Real-IP $remote_addr'
              - proxy_set_header: 'X-Forwarded-For $proxy_add_x_forwarded_for'
            - include: 'snippets/ssl_hardening_default.conf'
            # - include: 'snippets/letsencrypt.conf'
            - include: 'snippets/ssl_snakeoil.conf'
            - access_log: /var/log/nginx/workbench.fixme.example.net.access.log combined
            - error_log: /var/log/nginx/workbench.fixme.example.net.error.log

      arvados_workbench_upstream.conf:
        enabled: true
        overwrite: true
        config:
          - server:
            - listen: 'workbench.internal:9000'
            - server_name: workbench
            - root: /var/www/arvados-workbench/current/public
            - index:  index.html index.htm
            - passenger_enabled: 'on'
            # yamllint disable-line rule:line-length
            - access_log: /var/log/nginx/workbench.fixme.example.net-upstream.access.log combined
            - error_log: /var/log/nginx/workbench.fixme.example.net-upstream.error.log
