module Hominid
  class List < Base
   
    # LIST RELATED METHODS
    
    attr_reader :list_id
    attr_reader :attributes
    
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise StandardError.new('Please provide a List ID.') unless options[:id]
      @list_id = options.delete(:id)
      @attributes = options.delete(:attributes)
      super(options)
    end
    
    # Finder Methods
    
    def self.all
      # Get all lists for this mailchimp account
      new(:id => 0).call("lists").to_a.collect { |list| List.new(:id => list.delete('id'), :attributes => list) }
    end

    def self.find_by_name(name)
      # Find list by name
      all.find { |list| list.attributes['name'] =~ /#{name}/ }
    end

    def self.find_by_web_id(web_id)
      # Find list by name
      all.find { |list| (list.attributes['web_id'] == web_id.to_i) }
    end

    def self.find_by_id(id)
      # Find list by id
      all.find { |list| (list.list_id == id.to_s) }
    end

    def self.find(id_or_web_id)
      # List finder method
      all = self.all
      list = self.find_by_id(id_or_web_id.to_s).to_a + self.find_by_web_id(id_or_web_id.to_i).to_a
      return list.blank? ? nil : list.first
    end
    
    # List Methods
    
    def abuse_reports(start = 0, limit = 500, since = "2000-01-01 00:00:00")
      # Get all email addresses that complained about a given campaign
      #
      # Parameters:
      # start (Integer)   = Page number to start at. Defaults to 0.
      # limit (Integer)   = Number of results to return. Defaults to 500. Upper limit is 1000.
      # since (DateTime)  = Only return email reports since this date. Must be in YYYY-MM-DD HH:II:SS format (GMT).
      #
      # Returns:
      # An array of abuse reports for this list in the format:
      # 
      call("listAbuseReports", @list_id, start, limit, since)
    end
    
    def create_group(group)
      # Add a single Interest Group - if interest groups for the List are not yet
      # enabled, adding the first group will automatically turn them on.
      #
      # Parameters:
      # group (String) = The interest group to add.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listInterestGroupAdd", @list_id, group)
    end
    alias :interest_group_add :create_group
    
    def create_tag(tag, name, required = false)
      # Add a new merge tag to a given list
      #
      # Parameters:
      # tag       (String)  = The merge tag to add. Ex: FNAME
      # name      (String)  = The long description of the tag being added, used for user displays.
      # required  (Boolean) = TODO: set this up to accept the options available.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listMergeVarAdd", @list_id, tag, name, required)
    end
    alias :merge_var_add :create_tag
    
    def create_webhook(url, actions = {}, sources = {})
      # Add a new Webhook URL for the given list
      #
      # Parameters:
      # url     (String)  = A valid URL for the Webhook - it will be validated.
      # actions (Hash)    = A hash of actions to fire this Webhook for including:
      #                       :subscribe (Boolean) - defaults to true.
      #                       :unsubscribe (Boolean) - defaults to true.
      #                       :profile (Boolean) - defaults to true.
      #                       :cleaned (Boolean) - defaults to true.
      #                       :upemail (Boolean) - defaults to true.
      # sources (Hash)    = A hash of sources to fire this Webhook for including:
      #                       :user (Boolean) - defaults to true.
      #                       :admin (Boolean) - defaults to true.
      #                       :api (Boolean) - defaults to false.
      #
      # See the Mailchimp API documentation for more information.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listWebhookAdd", @list_id, url, actions, sources)
    end
    alias :webhook_add :create_webhook
    
    def delete_group(group)
      # Delete a single Interest Group - if the last group for a list
      #is deleted, this will also turn groups for the list off.
      #
      # Parameters:
      # group (String) = The interest group to delete.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listInterestGroupDel", @list_id, group)
    end
    alias :interest_group_del :delete_group

    def delete_tag(tag)
      # Delete a merge tag from a given list and all its members.
      # Seriously - the data is removed from all members as well!
      # Note that on large lists this method may seem a bit slower
      # than calls you typically make.
      #
      # Parameters:
      # tag (String) = 	The merge tag to delete.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listMergeVarDel", @list_id, tag)
    end
    alias :merge_var_del :delete_tag
    
    def delete_webhook(url)
      # Delete an existing Webhook URL from a given list.
      #
      # Parameters:
      # url (String) = The URL of a Webhook on this list.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listWebhookDel", @list_id, url)
    end
    alias :webhook_del :delete_webhook
    
    def groups
      # Get the list of interest groups for a given list, including
      # the label and form information.
      #
      # Returns:
      # A struct of interest groups for this list:
      # name        (String)  = Name for the Interest group.
      # form_field  (String)  = Gives the type of interest group: checkbox, radio, select, etc.
      # groups      (Array)   = Array of the group names
      #
      call("listInterestGroups", @list_id)
    end
    alias :interest_groups :groups
    
    def growth_history
      # Access the Growth History by Month for a given list.
      #
      # Parameters:
      # group (String) = The interest group to delete.
      #
      # Returns:
      # An array of months and growth with the following fields:
      # month     (String)  = The Year and Month in question using YYYY-MM format.
      # existing  (Integer) = Number of existing subscribers to start the month.
      # imports   (Integer) = Number of subscribers imported during the month.
      # optins    (Integer) = Number of subscribers who opted-in during the month.
      #
      call("listGrowthHistory", @list_id, tag)
    end
    
    def member_info(email)
      # Get all the information for a particular member of a list.
      #
      # Parameters:
      # email (String) = the member email address to get information for
      #                  OR the "id" for the member returned from listMemberInfo,
      #                  Webhooks, and Campaigns
      #
      # Returns:
      # An array of list member info with the following fields:
      # id          (String)  = The unique id for this email address on an account.
      # email       (String)  = The email address associated with this record.
      # email_type  (String)  = The type of emails this customer asked to get: html, text, or mobile.
      # merges      (Array)   = An associative array of all the merge tags and the data for those tags
      #                         for this email address. Note: Interest Groups are returned as comma
      #                         delimited strings - if a group name contains a comma, it will be escaped
      #                         with a backslash. ie, "," => "\,"
      # status      (String)  = The subscription status for this email address, either subscribed,
      #                         unsubscribed or cleaned.
      # ip_opt      (String)  = IP Address this address opted in from.
      # ip_signup   (String)  = IP Address this address signed up from.
      # campaign_id (String)  = If the user is unsubscribed and they unsubscribed from a specific campaign,
      #                         that campaign_id will be listed, otherwise this is not returned.
      # list        (Array)   = An associative array of the other lists this member belongs to - the key is
      #                         the list id and the value is their status in that list.
      # timestamp   (Date)    = The time this email address was added to the list
      #
      call("listMemberInfo", @list_id, email)
    end
    
    def members(status = "subscribed", since = "2000-01-01 00:00:00", start = 0, limit = 100)
      # Get all of the list members for a list that are of a particular status.
      # 
      # Parameters:
      # status  (String)    = One of subscribed, unsubscribed, cleaned, updated.
      # since   (Datetime)  = Pull all members whose status (subscribed/unsubscribed/cleaned) has changed or whose
      #                       profile (updated) has changed since this date/time (in GMT).
      # start   (Integer)   = The page number to start at - defaults to 0.
      # limit   (integer)   = The number of results to return - defaults to 100, upper limit set at 15000.
      #
      # Returns:
      # An array of list member structs:
      # email     (String)    = Member email address.
      # timestamp (DateTime)  = timestamp of their associated status date in GMT.
      #
      options = args.last.is_a?(::Hash) ? args.pop : {}
      status = args[0] || options[:status] || "subscribed"
      since = args[1] || options[:since] || "2000-01-01 00:00:00"
      start = args[2] || options[:start] || 0
      limit = args[3] || options[:limit] || 100
      call("listMembers", @list_id, status, since, start, limit)
    end
    
    def merge_tags()
      # Get the list of merge tags for a given list, including their name, tag, and required setting.
      #
      # Returns:
      # An array of merge tags for this list:
      # name  (String)  = Name of the merge field.
      # req   (Char)    = Denotes whether the field is required (Y) or not (N).
      # tag   (String)  = The merge tag.
      call("listMergeVars", @list_id)
    end
    alias :merge_vars :merge_tags
    
    def segment_test(options = {})
      # Allows one to test their segmentation rules before creating a campaign using them.
      #
      # Parameters:
      # options (Hash) = Please refer to the Mailchimp API documentation for more information.
      #
      # Returns:
      #
      #
      call("campaignSegmentTest", @list_id, options)
    end
    
    def subscribe(email, options = {})
      # Subscribe the provided email to a list.
      # 
      # Parameters:
      # email       (String) = The email address to subscribe.
      # merge_vars  (Hash)   = A hash of the merge tags that you want to include.
      #
      # Returns:
      # True on success, false on failure.
      #
      merge_tags = clean_merge_tags options[:merge_tags]
      options = apply_defaults_to({:email_type => "html"}.merge(options))
      call(
        "listSubscribe",
        @list_id,
        email,
        merge_tags,
        *options.values_at(
          :email_type,
          :double_opt_in,
          :update_existing,
          :replace_interests,
          :send_welcome
        )
      )
    end
    
    def subscribe_many(subscribers, options = {})
      # Subscribe a batch of email addresses to a list at once.
      # 
      # Parameters:
      # subscribers (Array) = An array of email addresses to subscribe.
      # merge_vars  (Hash)  = A hash of subscription options. See the Mailchimp API documentation.
      #
      # Returns:
      # An array of result counts and errors:
      # success_count (Integer) = Number of email addresses that were succesfully added/updated.
      # error_count   (Integer) = Number of email addresses that failed during addition/updating.
      # errors        (Array)   = Array of error structs. Each error struct will contain "code",
      #                           "message", and the full struct that failed.
      #
      subscribers = subscribers.collect { |subscriber| clean_merge_tags(subscriber) }
      options = apply_defaults_to({:update_existing => true}.merge(options))
      call("listBatchSubscribe", @list_id, subscribers, *options.values_at(:double_opt_in, :update_existing, :replace_interests))
    end
    alias :batch_subscribe :subscribe_many
    
    def unsubscribe(current_email, options = {})
      # Unsubscribe the given email address from the list.
      #
      # Parameters:
      # current_email (String)  = The email address to unsubscribe OR the email "id".
      # options       (Hash)    = A hash of unsubscribe options including:
      #                             :delete_member (defaults to false)
      #                             :send_goodbye (defaults to true)
      #                             :send_notify (defaults to true).
      #
      # Returns:
      # True on success, false on failure
      #
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listUnsubscribe", @list_id, current_email, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end
    
    def unsubscribe_many(emails, options = {})
      # Unsubscribe a batch of email addresses to a list.
      #
      # Parameters:
      # emails  (Array) = An array of email addresses to unsubscribe.
      # options (Hash)  = A hash of unsubscribe options including:
      #                     :delete_member (defaults to false)
      #                     :send_goodbye (defaults to true)
      #                     :send_notify (defaults to false)
      #
      # Returns:
      #
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listBatchUnsubscribe", @list_id, emails, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end
    alias :batch_unsubscribe :unsubscribe_many
    
    def update_group(old_name, new_name)
      # Change the name of an Interest Group.
      #
      # Parameters:
      # old_name (String) = 	The interest group name to be changed.
      # new_name (String) = 	The new interest group name to be set.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("listInterestGroupUpdate", @list_id, old_name, new_name)
    end
    
    def update_member(emal, merge_tags = {}, email_type = "html", replace_interests = true)
      # Edit the email address, merge fields, and interest groups for a list member.
      #
      # Parameters:
      # email             (String)  =	The current email address of the member to update OR the "id" for the member.
      # merge_tags        (Hash)    = Hash of new field values to update the member with.
      #                               Ex: {FNAME => 'Bob', :LNAME => 'Smith'}
      # email_type        (String)  = One of 'html', 'text', or 'mobile'.
      # replace_interests (Boolean) = Whether or not to replace the interest groups with the updated groups provided.
      #
      # Returns:
      # True on success, false on failure
      #
      call("listUpdateMember", @list_id, current_email, merge_tags, email_type, replace_interests)
    end
    
    def webhooks
      # Return the Webhooks configured for the given list.
      #
      # Returns:
      # An array of webhooks for this list including:
      # url     (String)  = The URL for this Webhook.
      # action  (Array)   = The possible actions and whether they are enabled.
      # sources (Array)   = The possible sources and whether they are enabled.
      #
      call("listWebhooks", @list_id)
    end
    
  end
end