module Hominid

  class Security < Base
   
    # Security related methods
    # --------------------------------
    
    def self.add_api_key
      new.call("apikeyAdd")
    end

    def self.expire_api_key
      new.call("apikeyExpire")
    end

    def self.api_keys(include_expired = false)
      new.call("apikeys", include_expired)
    end
    
  end
end