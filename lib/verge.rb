module Verge
  autoload :Crypto, "verge/crypto"
  
  module Server
    autoload :Base, "verge/server/base"
    
    autoload :Config, "verge/server/config"
    autoload :Exec, "verge/server/exec"

    autoload :User, "verge/server/models"
    autoload :SignedToken, "verge/server/models"
    autoload :Token, "verge/server/models"
    autoload :Site, "verge/server/models"
  end
  
  autoload :Client, "verge/client"
end
