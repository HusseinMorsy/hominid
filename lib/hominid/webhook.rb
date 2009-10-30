module Hominid

  class Webhook < Base
    # Expects a hash of POST data generated from Mailchimp:
    #
    # "type": "unsubscribe", 
    # "fired_at": "2009-03-26 21:54:00", 
    # "data[email]": "sample@emailaddress.com"
    #
    # Simple Usage:
    #
    # h = Hominid::Webhook.new({"type" => "subscribe", ...})
    #
    # Returns an object with the following methods (NOTE: Not all methods are available
    # for all event types. Refer to http://www.mailchimp.com/api/webhooks/ for information
    # on what data will be available for each event):
    # 
    # h.event               <= (String)     The event that fired the request. Possible events are:
    #                                       "subscribe", "unsubscribe", "profile", "upemail", "cleaned"
    # h.fired_at            <= (Datetime)   When the webhook request was fired.
    # h.id                  <= (String)     The ID of the webhook request.
    # h.list_id             <= (String)     The ID of the list that generated the request.
    # h.email               <= (String)     The email address of the subscriber that generated the request.
    # h.email_type          <= (String)     The email type of the subscriber that generated the request.
    # h.first_name          <= (String)     The first name of the subscriber (if available).
    # h.last_name           <= (String)     The first name of the subscriber (if available).
    # h.interests           <= (Array)      An array of the interest groups.
    
    attr_reader :request
    
    def initialize(*args)
      post_data = args.last
      raise HominidError.new('Please provide the POST data from a Mailchimp webhook request.') unless post_data.is_a?(Hash)
      post_data.merge!({"event" => "#{post_data.delete('type')}"})
      @request = hash_to_object(post_data)
    end
    
    def event
      self.request.event if self.request.event
    end
    
    def fired_at
      self.request.fired_at.to_datetime if self.request.fired_at
    end
    
    def id
      self.request.data.id if self.request.data.id
    end
    
    def list_id
      self.request.data.list_id if self.request.data.list_id
    end
    
    def first_name
      self.request.data.merges.fname if self.request.data.merges.fname
    end
    
    def last_name
      self.request.data.merges.lname if self.request.data.merges.lname
    end
    
    def interests
      self.request.data.merges.interests.split(',') if self.request.data.merges.interests
    end
    
    private

    def hash_to_object(object)
      return case object
      when Hash
        object = object.clone
        object.each do |key, value|
          object[key.downcase] = hash_to_object(value)
          # TODO: Replace keys with lowercase, rather than duplicating
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