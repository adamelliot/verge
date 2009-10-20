Factory.sequence(:login) { |n| "verge-#{n}" }
Factory.sequence(:domain) { |n| "site-#{n}.com" }

Factory.define(:user, :class => Verge::Server::User) do |u|
  u.login { Factory.next(:login) }
  u.password '0rbital'
end

Factory.define(:site, :class => Verge::Server::Site) do |s|
  s.domain { Factory.next(:domain) }
end

Factory.define(:signed_token, :class => Verge::Server::SignedToken) do |s|
  s.token_id 1
  s.site_id 1
  s.value { Verge::Crypto.token }
end