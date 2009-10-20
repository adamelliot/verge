require 'rubygems'

module Verge
  autoload :Crypto, "verge/crypto"
  
  module Server
    autoload :Base, "verge/server/base"

    autoload :User, "verge/server/models"
    autoload :SignedToken, "verge/server/models"
    autoload :Token, "verge/server/models"
    autoload :Site, "verge/server/models"
  end
end