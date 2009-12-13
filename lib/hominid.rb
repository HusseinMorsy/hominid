require 'xmlrpc/client'
require 'ostruct'

module Hominid

  class StandardError < ::StandardError
  end

  class APIError < StandardError
    def initialize(error)
      super("<#{error.faultCode}> #{error.message}")
    end
  end
  
  class AlreadySubscribed < APIError
  end

  class AlreadyUnsubscribed < APIError
  end
  
  class CampaignError < APIError
  end
  
  class InterestGroupError < APIError
  end
  
  class InvalidInterestGroup < InterestGroupError
  end
  
  class InvalidEcommerceOrder < APIError
  end

  class ListError < APIError
  end

  class ListEmailError < ListError
  end

  class ListMergeError < ListError
  end

  class NotExists < APIError
  end

  class NotSubscribed < APIError
  end

  class CommunicationError < StandardError
    def initialize(message)
      super(message)
    end
  end
end

require 'hominid/list'
require 'hominid/campaign'
require 'hominid/helper'
require 'hominid/base'

