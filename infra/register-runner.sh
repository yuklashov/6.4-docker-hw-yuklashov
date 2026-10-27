#!/usr/bin/env bash
set -euo pipefail
test "$(id -u)" = 0
test -s /root/netology-runner-token
install -d -m 700 /srv/gitlab-runner/config
docker run --rm --network host \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /root/netology-runner-token:/run/registration-token:ro \
  --entrypoint /bin/sh gitlab/gitlab-runner:alpine -c '
    exec gitlab-runner register --non-interactive \
      --url http://127.0.0.1:18080 \
      --token "$(cat /run/registration-token)" \
      --executor docker \
      --docker-image golang:1.27.3 \
      --docker-network-mode host \
      --docker-memory 2g \
      --docker-cpus 1 \
      --description netology-docker-runner
  '
sed -i 's/^concurrent = 1$/concurrent = 2/' /srv/gitlab-runner/config/config.toml
docker run -d --name netology-gitlab-runner --restart unless-stopped \
  --network host \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:alpine
rm /root/netology-runner-token
printf 'Docker Runner started. Configuration contains credentials; do not publish it.\n'
