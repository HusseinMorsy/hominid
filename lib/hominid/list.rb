module Hominid

  class List < Base
    
    # List related methods
    # --------------------------------

    attr_reader :list_id
    attr_reader :attributes
    
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise HominidError.new('Please provide a List ID.') unless options[:id]
      @list_id = options.delete(:id)
      @attributes = options.delete(:attributes)
      super(options)
    end

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

    def create_group(group)
      # Add an interest group to a list
      call("listInterestGroupAdd", @list_id, group)
    end

    def create_tag(tag, name, required = false)
      # Add a merge tag to a list
      call("listMergeVarAdd", @list_id, tag, name, required)
    end

    def delete_group(group)
      # Delete an interest group for a list
      call("listInterestGroupDel", @list_id, group)
    end

    def delete_tag(tag)
      # Delete a merge tag and all its members
      call("listMergeVarDel", @list_id, tag)
    end

    def groups()
      # Get the interest groups for a list
      call("listInterestGroups", @list_id)
    end

    def member_info(email)
      # Get a member of a list
      call("listMemberInfo", @list_id, email)
    end

    def members(status = "subscribed", since = "2000-01-01 00:00:00", start = 0, limit = 100)
      # Get members of a list based on status
      # Select members based on one of the following statuses:
      #   'subscribed'
      #   'unsubscribed'
      #   'cleaned'
      #   'updated'
      #
      # Select members that have updated their status or profile by providing
      # a "since" date in the format of YYYY-MM-DD HH:MM:SS
      call("listMembers", @list_id, status, since, start, limit)
    end

    def merge_tags()
      # Get the merge tags for a list
      call("listMergeVars", @list_id)
    end

    def subscribe(email, options = {})
      # Subscribe a member to this list
      options = apply_defaults_to({:email_type => "html"}.merge(options))
      call(
        "listSubscribe",
        @list_id,
        email,
        *options.values_at(
          :merge_tags,
          :email_type,
          :double_opt_in,
          :update_existing,
          :replace_interests,
          :send_welcome
        )
      )
    end

    def subscribe_many(subscribers, options = {})
      # Subscribe a batch of members
      # subscribers(array) = [{:EMAIL => 'example@email.com', :EMAIL_TYPE => 'html'}]
      options = apply_defaults_to({:update_existing => true}.merge(options))
      call("listBatchSubscribe", @list_id, subscribers, *options.values_at(:double_opt_in, :update_existing, :replace_interests))
    end
    
    def unsubscribe(current_email, options = {})
      # Unsubscribe a list member
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listUnsubscribe", @list_id, current_email, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end

    def unsubscribe_many(emails, options = {})
      # Unsubscribe an array of email addresses
      # emails(array) = ['first@email.com', 'second@email.com']
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listBatchUnsubscribe", @list_id, emails, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end

    def update_member(current_email, merge_tags = {}, email_type = "html")
      # Update a member of this list
      call("listUpdateMember", @list_id, current_email, merge_tags, email_type, true)
    end

  end
end