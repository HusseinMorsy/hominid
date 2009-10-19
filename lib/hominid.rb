require 'xmlrpc/client'
 
module Hominid
 
  class HominidError < StandardError
    def initialize(error)
      super("<#{error.faultCode}> #{error.message}")
    end
  end
 
  class HominidListError < HominidError
  end
 
  class HominidListEmailError < HominidListError
  end
 
  class HominidListMergeError < HominidListError
  end
 
  class AlreadySubscribed < HominidListEmailError
  end
 
  class AlreadyUnsubscribed < HominidListEmailError
  end
 
  class NotExists < HominidListEmailError
  end
 
  class NotSubscribed < HominidListEmailError
  end
 
  class HominidCommunicationError < HominidError
    def initialize(message)
      super(message)
    end
  end
 
end
 
require 'hominid/base'