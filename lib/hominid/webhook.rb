module Hominid

  class Webhook < Base
    # Expects a hash of POST data generated from Mailchimp:
    #
    # "type": "unsubscribe", 
    # "fired_at": "2009-03-26 21:54:00", 
    # "data[email]": "sample@emailaddress.com"
    #
    # Returns an OpenStruct matching the request POST data:
    #
    # Subscribe Event:
    # webhook.type              => "subscribe"
    # webhook.fired_at          => "2009-03-26 21:35:57"
    # webhook.data.id           => "8a25ff1d98"
    # webhook.data.list_id      => "8a25ff1d98"
    # webhook.data.merges.email => "sample@emailaddress.com"
    # ..
    # Check the Mailchimp API Webhooks Documentation for
    # more information about the structure of webhook
    # requests: http://www.mailchimp.com/api/webhooks/
    
    def initialize(*post_data)
      raise HominidError.new('Please pass the POST data from a Mailchimp webhook.') unless post_data.is_a?(Hash)
      webhook_data = hash_to_object(post_data)
      super(webhook_data)
    end
    
    private

    def hash_to_object(object)
      return case object
      when Hash
        object = object.clone
        object.each do |key, value|
          object[key] = hash_to_object(value)
        end
        OpenStruct.new(object)
      when Array
        object = object.clone
        object.map! { |i| hash_to_object(i) }
      else
        object
      end
    end

  end
end