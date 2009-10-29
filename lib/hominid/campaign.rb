module Hominid

  class Campaign < Base

    # Campaign related methods
    # --------------------------------

    attr_reader :campaign_id
    attr_reader :attributes

    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise StandardError.new('Please provide a Campaign ID.') unless options[:id]
      @campaign_id = options.delete(:id)
      @attributes = options.delete(:attributes)
      super(options)
    end

    def self.all
      # Get all campaigns for this mailchimp account
      new(:id => 0).call("campaigns").to_a.collect { |c| Campaign.new(:id => c.delete('id'), :attributes => c) }
    end

    def self.find_by_list_name(list_name)
      new(:id => 0).call("campaigns", {:list_id => List.find_by_name(list_name).list_id}).to_a.collect { |c| Campaign.new(:id=> c.delete('id'), :attributes => c) }
    end

    def self.find_by_list_id(list_id)
      # Find all campaigns for the given list
      new(:id => 0).call("campaigns", {:list_id => list_id}).to_a.collect { |c| Campaign.new(:id=> c.delete('id'), :attributes => c) }
    end

    def self.find_by_title(title)
      # Find campaign by title
      all.find { |c| c.attributes['title'] =~ /#{title}/ }
    end

    def self.find_by_type(type)
      # Find campaign by type. Possible choices are:
      #   'regular'
      #   'plaintext'
      #   'absplit'
      #   'rss'
      #   'inspection'
      #   'trans'
      #   'auto'
      all.find { |campaign| campaign.attributes['type'] =~ /#{type}/ }
    end

    def self.find_by_web_id(web_id)
      # Find campaigns by web_id
      all.find { |campaign| campaign.attributes['web_id'] =~ /#{web_id}/ }
    end

    def self.find_by_id(id)
      # Find campaign by id
      all.find { |campaign| (campaign.campaign_id == id.to_s) }
    end

    def self.find(id_or_web_id)
      # Campaign finder method
      all = self.all
      campaign = self.find_by_id(id_or_web_id.to_s).to_a + self.find_by_web_id(id_or_web_id.to_i).to_a
      return campaign.blank? ? nil : campaign.first
    end

    def self.create(type = 'regular', options = {}, content = {}, segment_options = {}, type_opts = {})
      # Create a new campaign
      # The options hash should be structured as follows:
      #
      #   :list_id        = (string)  The ID of the list to send this campaign to.
      #   :subject        = (string)  The subject of the campaign.
      #   :from_email     = (string)  The email address this campaign will come from.
      #   :from_name      = (string)  The name that this campaign will come from.
      #   :to_email       = (string)  The To: name recipients will see.
      #   :template_id    = (integer) The ID of the template to use for this campaign (optional).
      #   :folder_id      = (integer) The ID of the folder to file this campaign in (optional).
      #   :tracking       = (array)   What to track for this campaign (optional).
      #   :title          = (string)  Internal title for this campaign (optional).
      #   :authenticate   = (boolean) Set to true to authenticate campaign (optional).
      #   :analytics      = (array)   Google analytics tags (optional).
      #   :auto_footer    = (boolean) Auto-generate the footer (optional)?
      #   :inline_css     = (boolean) Inline the CSS styles (optional)?
      #   :generate_text  = (boolean) Auto-generate text from HTML email (optional)?
      #
      # Visit http://www.mailchimp.com/api/1.2/campaigncreate.func.php for more information about creating
      # campaigns via the API.
      #
      new(:id => 0).call("campaignCreate", type, options, content, segment_options, type_opts)
      ## TODO: Return the new campaign with the ID returned from the API
    end

    def self.templates
      # Get the templates for this account
      new(:id => 0).call("campaignTemplates")
    end

    def add_order(order)
      # Attach Ecommerce Order Information to a campaign.
      # The order hash should be structured as follows:
      #
      #   :id             = (string)  the order id
      #   :email_id       = (string)  email id of the subscriber (mc_eid query string)
      #   :total          = (double)  Show only campaigns with this from_name.
      #   :shipping       = (string)  *optional - the total paid for shipping fees.
      #   :tax            = (string)  *optional - the total tax paid.
      #   :store_id       = (string)  a unique id for the store sending the order in
      #   :store_name     = (string)  *optional - A readable name for the store, typicaly the hostname.
      #   :plugin_id      = (string)  the MailChimp-assigned Plugin Id. Using 1214 for the moment.
      #   :items          = (array)   the individual line items for an order, using the following keys:
      #
      #     :line_num      = (integer) *optional - line number of the item on the order
      #     :product_id    = (integer) internal product id
      #     :product_name  = (string)  the name for the product_id associated with the item
      #     :category_id   = (integer) internal id for the (main) category associated with product
      #     :category_name = (string)  the category name for the category id
      #     :qty           = (double)  the quantity of items ordered
      #     :cost          = (double)  the cost of a single item (i.e., not the extended cost of the line)
      order.merge(:campaign_id => @campaign_id)
      call("campaignEcommAddOrder", order)
    end

    def campaign_stats()
      # Get the stats of a campaign
      call("campaignStats", @campaign_id)
    end

    # Get the HTML & text content for a campaign
    # :for_archive        = (boolean) default true, true returns the content as it would appear in the archive, false returns the raw HTML/text
    def campaign_content(for_archive = true)
      # Get the content of a campaign
      call("campaignContent", @campaign_id, for_archive)
    end

    def delete_campaign()
      # Delete a campaign
      call("campaignDelete", @campaign_id)
    end

    def replicate_campaign()
      # Replicate a campaign (returns ID of new campaign)
      call("campaignReplicate", @campaign_id)
    end

    def schedule_campaign(time = "#{1.day.from_now}")
      # Schedule a campaign
      ## TODO: Add support for A/B Split scheduling
      call("campaignSchedule", @campaign_id, time)
    end

    def send_now()
      # Send a campaign
      call("campaignSendNow", @campaign_id)
    end

    # Send a test of a campaign
    def send_test(emails = {})
      call("campaignSendTest", @campaign_id, emails)
    end

    def update(name, value)
      # Update a campaign
      call("campaignUpdate", @campaign_id, name, value)
    end

    def unschedule()
      # Unschedule a campaign
      call("campaignUnschedule", @campaign_id)
    end
  end
end

