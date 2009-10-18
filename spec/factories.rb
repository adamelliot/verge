Factory.sequence(:login) { |n| "verge-#{n}" }
Factory.sequence(:uri) { |n| "http://site-#{n}.com" }

Factory.define(:user, :class => Verge::Server::User) do |u|
  u.login { Factory.next(:login) }
  u.password '0rbital'
end

Factory.define(:site, :class => Verge::Server::Site) do |s|
  s.uri { Factory.next(:uri) }
end

Factory.define(:signed_key, :class => Verge::Server::SignedKey) do |s|
  s.user_key_id 1
  s.site_id 1
  s.value { Verge::Crypto.token }
end