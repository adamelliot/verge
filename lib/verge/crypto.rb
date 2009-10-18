require 'digest/sha2'

module Verge
  module Crypto
    extend self

    def token # nodoc #
      Digest::SHA512.hexdigest((1..10).collect{ rand.to_s }.join + Time.now.usec.to_s)
    end
    
    def digest(*values) # nodoc #
      Digest::SHA512.hexdigest values.join
    end
  end
end
