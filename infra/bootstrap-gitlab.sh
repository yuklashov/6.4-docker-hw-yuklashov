#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
test "$(id -u)" = 0
cloud-init status --wait || echo "cloud-init status exit $? (continuing)"
dpkg --configure -a || true
apt-get update -qq
apt-get install -y curl ca-certificates openssh-server docker.io git jq
systemctl enable --now docker
curl --fail --location --silent --show-error \
  https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh \
  -o /root/gitlab-repository-setup.sh
bash /root/gitlab-repository-setup.sh
# The web interface is reached over an SSH tunnel, not a public HTTP port.
mkdir -p /etc/gitlab
cat >/etc/gitlab/gitlab.rb <<'RUBY'
external_url 'http://127.0.0.1:18080'
nginx['listen_addresses'] = ['127.0.0.1']
prometheus_monitoring['enable'] = false
gitlab_rails['gitlab_signup_enabled'] = false
puma['worker_processes'] = 2
sidekiq['concurrency'] = 5
RUBY
EXTERNAL_URL='http://127.0.0.1:18080' apt-get install -y gitlab-ce
gitlab-ctl status
systemctl is-active netology-lab-poweroff.timer
docker pull gitlab/gitlab-runner:alpine
docker pull golang:1.27.3
printf '\nGitLab bootstrap completed.\n'
touch /root/netology-bootstrap.complete
