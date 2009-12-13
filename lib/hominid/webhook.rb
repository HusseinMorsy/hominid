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
    # h = Hominid::Webhook.new(params)
    #
    # Sample params from Mailchimp webhook:
    # params => { "type" => "subscribe",
    #             "fired_at" => "2009-03-26 21:35:57",
    #             "data" => { "id" => "8a25ff1d98",
    #                         "list_id" => "8a25ff1d98",
    #                         "email" => "api@mailchimp.com",
    #                         "email_type" => "html",
    #                         "merges" => {"EMAIL" => "api@mailchimp.com",
    #                                     "FNAME" => "Brian",
    #                                     "LNAME" => "Getting",
    #                                     "INTERESTS" => "Group1,Group2"},
    #                         "ip_opt" => "10.20.10.30",
    #                         "ip_signup" => "10.20.10.30" }}
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
    # h.ip_opt              <= (String)     The opt in IP address.
    # h.ip_signup           <= (String)     The signup IP address.
    #
    
    attr_reader :request
    
    def initialize(*args)
      post_data = args.last
      raise StandardError.new('Please provide the POST data from a Mailchimp webhook request.') unless post_data.is_a?(Hash)
      post_data.merge!({"event" => "#{post_data.delete('type')}"})
      @request = hash_to_object(post_data)
    end
    
    
    def email
      self.request.data.email if self.request.data.email
    end
    
    def email_type
      self.request.data.email_type if self.request.data.email_type
    end
    
    def event
      self.request.event if self.request.event
    end
    
    def fired_at
      self.request.fired_at.to_datetime if self.request.fired_at
    end
    
    def first_name
      self.request.data.merges.fname if self.request.data.merges.fname
    end
    
    def last_name
      self.request.data.merges.lname if self.request.data.merges.lname
    end
    
    def id
      self.request.data.id if self.request.data.id
    end
    
    def interests
      self.request.data.merges.interests.split(',') if self.request.data.merges.interests
    end
    
    def ip_opt
      self.request.data.ip_opt if self.request.data.ip_opt
    end
    
    def ip_signup
      self.request.data.ip_signup if self.request.data.ip_signup
    end
    
    def list_id
      self.request.data.list_id if self.request.data.list_id
    end
    
    def new_email
      self.request.data.new_email if self.request.data.new_email
    end
    
    def old_email
      self.request.data.old_email if self.request.data.old_email
    end
    
    def reason
      self.request.data.reason if self.request.data.reason
    end
    
    private

    def hash_to_object(object)
      return case object
      when Hash
        object = object.clone
        object.each do |key, value|
          object[key.downcase] = hash_to_object(value)
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