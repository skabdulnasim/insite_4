json.data(@users) do |user|
  json.extract! user, :id
  json.full_name "#{user.profile.full_name}"
end