module Hominid

  ## List related methods
  class List < Base

    attr_reader :list_id
    attr_reader :attributes

    # Get all of the lists for this mailchimp account
    def self.all
      new(:id => 0).call("lists").to_a.collect { |list| List.new(:id => list.delete('id'), :attributes => list) }
    end

    def self.find_by_name(name)
      all.find { |list| list.attributes['name'] =~ /#{name}/ }
    end

    def self.find_by_web_id(web_id)
      all.find { |list| (list.attributes['web_id'] == web_id.to_i) }
    end

    def self.find_by_id(id)
      all.find { |list| (list.list_id == id.to_s) }
    end

    def self.find(id_or_web_id)
      all = self.all
      list = self.find_by_id(id_or_web_id.to_s).to_a + self.find_by_web_id(id_or_web_id.to_i).to_a
      return list.blank? ? nil : list.first
    end

    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise HominidError.new('Please provide a List ID.') unless options[:id]

      @list_id = options.delete(:id)
      @attributes = options.delete(:attributes)
      super(options)
    end

    # Add an interest group to a list
    def create_group(group)
      call("listInterestGroupAdd", @list_id, group)
    end

    # Add a merge tag to a list
    def create_tag(tag, name, required = false)
      call("listMergeVarAdd", @list_id, tag, name, required)
    end

    # Delete an interest group for a list
    def delete_group(group)
      call("listInterestGroupDel", @list_id, group)
    end

    # Delete a merge tag and all its members
    def delete_tag(tag)
      call("listMergeVarDel", @list_id, tag)
    end

    # Get the interest groups for a list
    def groups()
      call("listInterestGroups", @list_id)
    end

    # Get a member of a list
    def member_info(email)
      call("listMemberInfo", @list_id, email)
    end

    # Get members of a list based on status
    # Select members based on one of the following statuses:
    #   'subscribed'
    #   'unsubscribed'
    #   'cleaned'
    #   'updated'
    #
    # Select members that have updated their status or profile by providing
    # a "since" date in the format of YYYY-MM-DD HH:MM:SS
    #
    def members(status = "subscribed", since = "2000-01-01 00:00:00", start = 0, limit = 100)
      call("listMembers", @list_id, status, since, start, limit)
    end

    # Get the merge tags for a list
    def merge_tags()
      call("listMergeVars", @list_id)
    end

    # Subscribe a member
    def subscribe(email, options = {})
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

    # Subscribe a batch of members
    # subscribers = {:EMAIL => 'example@email.com', :EMAIL_TYPE => 'html'}
    def subscribe_many(subscribers, options = {})
      options = apply_defaults_to({:update_existing => true}.merge(options))
      call("listBatchSubscribe", @list_id, subscribers, *options.values_at(:double_opt_in, :update_existing, :replace_interests))
    end

    # Unsubscribe a list member
    def unsubscribe(current_email, options = {})
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listUnsubscribe", @list_id, current_email, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end

    # Unsubscribe an array of email addresses
    # emails = ['first@email.com', 'second@email.com']
    def unsubscribe_many(emails, options = {})
      options = apply_defaults_to({:delete_member => true}.merge(options))
      call("listBatchUnsubscribe", @list_id, emails, *options.values_at(:delete_member, :send_goodbye, :send_notify))
    end

    # Update a member of this list
    def update_member(current_email, merge_tags = {}, email_type = "")
      call("listUpdateMember", @list_id, current_email, merge_tags, email_type, true)
    end

  end
end

