# gitlab-rails runner: временный PAT root для автоматизации стенда (GitLab 19: токену нужна организация).
# Публичный ключ оператора в GitLab не добавляется: push идёт по HTTP через SSH-туннель.
require 'json'
require 'date'
require 'tempfile'
user = User.find_by_username!('root')
ApplicationSetting.current.update!(signup_enabled: false)
org = (user.respond_to?(:organization) && user.organization) || Organizations::Organization.default_organization
attrs = { name: 'Temporary Netology lab automation', scopes: ['api'], expires_at: Date.today + 1 }
token = begin
  user.personal_access_tokens.create!(attrs.merge(organization: org))
rescue ActiveModel::UnknownAttributeError, ArgumentError
  user.personal_access_tokens.create!(attrs)
end
# Run from a script readable by the GitLab git user; /root is not accessible to it.
file = Tempfile.create(['netology-access-', '.json'])
file.chmod(0600)
file.write(JSON.generate({ token: token.token, username: user.username }))
path = file.path
file.close
puts "Temporary lab access saved in mode-0600 file: #{path}. Revoke the token and delete the file after use."
