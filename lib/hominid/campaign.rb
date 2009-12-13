module Hominid
  class Campaign < Base
    
    # CAMPAIGN RELATED METHODS
    
    attr_reader :campaign_id
    attr_reader :attributes

    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise StandardError.new('Please provide a Campaign ID.') unless options[:id]
      @campaign_id = options.delete(:id)
      @attributes = options.delete(:attributes)
      super(options)
    end
    
    # Finder Methods

    def self.all
      # Get all campaigns for this mailchimp account
      new(:id => 0).call("campaigns").to_a.collect { |c| Campaign.new(:id => c.delete('id'), :attributes => c) }
    end

    def self.find_by_list_name(list_name)
      # Get all campaigns for the given list.
      new(:id => 0).call("campaigns", {:list_id => List.find_by_name(list_name).list_id}).to_a.collect { |c| Campaign.new(:id=> c.delete('id'), :attributes => c) }
    end

    def self.find_by_list_id(list_id)
      # Get all campaigns for the given list.
      new(:id => 0).call("campaigns", {:list_id => list_id}).to_a.collect { |c| Campaign.new(:id=> c.delete('id'), :attributes => c) }
    end

    def self.find_by_title(title)
      # Find a campaign by title.
      all.find { |c| c.attributes['title'] =~ /#{title}/ }
    end

    def self.find_by_type(type)
      # Find campaigns by type. Possible choices are:
      #   'regular'
      #   'plaintext'
      #   'absplit'
      #   'rss'
      #   'inspection'
      #   'trans'
      #   'auto'
      #
      all.find { |campaign| campaign.attributes['type'] =~ /#{type}/ }
    end

    def self.find_by_web_id(web_id)
      # Find campaigns by web_id.
      all.find { |campaign| campaign.attributes['web_id'] == web_id.to_i }
    end

    def self.find_by_id(id)
      # Find a campaign by id.
      all.find { |campaign| (campaign.campaign_id == id.to_s) }
    end

    def self.find(id_or_web_id)
      # Campaign finder method.
      all = self.all
      campaign = self.find_by_id(id_or_web_id.to_s).to_a + self.find_by_web_id(id_or_web_id.to_i).to_a
      return campaign.blank? ? nil : campaign.first
    end
    
    # ActiveRecord-Type Methods
    
    def self.create(type = 'regular', options = {}, content = {}, segment_options = {}, type_opts = {})
      # Create a new draft campaign to send.
      #
      # Parameters:
      # type            (String)  = One of "regular", "plaintext", "absplit", "rss", "trans" or "auto".
      # options         (Hash)    = A hash of options for creating this campaign including:
      #   :list_id        = (String)  The ID of the list to send this campaign to.
      #   :subject        = (String)  The subject of the campaign.
      #   :from_email     = (String)  The email address this campaign will come from.
      #   :from_name      = (String)  The name that this campaign will come from.
      #   :to_email       = (String)  The To: name recipients will see.
      #   :template_id    = (Integer) The ID of the template to use for this campaign (optional).
      #   :folder_id      = (Integer) The ID of the folder to file this campaign in (optional).
      #   :tracking       = (Array)   What to track for this campaign (optional).
      #   :title          = (String)  Internal title for this campaign (optional).
      #   :authenticate   = (Boolean) Set to true to authenticate campaign (optional).
      #   :analytics      = (Array)   Google analytics tags (optional).
      #   :auto_footer    = (Boolean) Auto-generate the footer (optional)?
      #   :inline_css     = (Boolean) Inline the CSS styles (optional)?
      #   :generate_text  = (Boolean) Auto-generate text from HTML email (optional)?
      # content         (Hash)    = The content for this campaign - use a struct with the following keys:
      #   :html         (String)  = The HTML content of the campaign.
      #   :text         (String)  = The text content of the campaign.
      #   :url          (String)  = A URL to pull content from. This will override other content settings.
      #   :archive      (String)  = To send a Base64 encoded archive file for Mailchimp to import all media from.
      #   :archive_type (String)  = Only necessary for the "archive" option. Supported formats are: zip, tar.gz,
      #                             tar.bz2, tar, tgz, tbz. Defaults to zip. (optional)
      # segment_options (Hash)    = Segmentation options. See the Mailchimp API documentation for more information.
      # type_opts       (Hash)    = An array of options for this campaign type. See the Mailchimp API documentation for
      #                             for more information.
      #
      # Returns:
      # The ID for the created campaign. (String)
      #
      new(:id => 0).call("campaignCreate", type, options, content, segment_options, type_opts)
      # TODO: Should we return the new campaign instead of the ID returned from the API?
      #       This would make it act a bit more like ActiveRecord.
    end
    
    def self.folders
      # List all the folders for a user account.
      #
      # Returns:
      # An array of templates for this campaign including:
      #   folder_id (Integer) = Folder Id for the given folder, this can be used in the campaigns() function to filter on.
      #   name      (String)  = Name of the given folder.
      #
      new(:id => 0).call("campaignFolders")
    end
    
    def self.templates
      # Retrieve all templates defined for your user account.
      #
      # Returns:
      # An array of templates for this campaign including:
      #   id        (Integer) = The ID of the template.
      #   name      (String)  = The name of the template.
      #   layout    (String)  = The layout of the template - "basic", "left_column", "right_column", or "postcard".
      #   sections  (Array)   = An associative array of editable sections in the template that can accept custom HTML
      #                         when sending a campaign.
      #
      new(:id => 0).call("campaignTemplates")
    end
    
    # Campaign Methods
    
    def abuse_reports(start = 0, limit = 500, since = "2000-01-01 00:00:00")
      # Get all email addresses that complained about a given campaign.
      #
      # Parameters:
      # start (Integer)   = Page number to start at. Defaults to 0.
      # limit (Integer)   = Number of results to return. Defaults to 500. Upper limit is 1000.
      # since (DateTime)  = Only return email reports since this date. Must be in YYYY-MM-DD HH:II:SS format (GMT).
      #
      # Returns:
      # An array of abuse reports for this list in the format:
      # 
      call("campaignAbuseReports", @campaign_id, start, limit, since)
    end
    
    def advice
      # Retrieve the text presented in our app for how a campaign performed and any advice we may have for you - best
      # suited for display in customized reports pages. Note: some messages will contain HTML - clean tags as necessary.
      #
      # Returns:
      # An array of advice on the campaign's performance including:
      #   msg   (String) = Advice message.
      #   type  (String) = One of: negative, positive, or neutral.
      #
      call("campaignAdvice", @campaign_id)
    end
    
    def add_order(order)
      # Attach Ecommerce Order Information to a Campaign.
      #
      # Parameters:
      # order (Hash) = A hash of order information including:
      #   id          (String)  = The order id
      #   email_id    (String)  = Email id of the subscriber (mc_eid query string)
      #   total       (Double)  = Show only campaigns with this from_name.
      #   shipping    (String)  = The total paid for shipping fees. (optional)
      #   tax         (String)  = The total tax paid. (optional)
      #   store_id    (String)  = A unique id for the store sending the order in
      #   store_name  (String)  = A readable name for the store, typicaly the hostname. (optional)
      #   plugin_id   (String)  = The MailChimp-assigned Plugin Id. Using 1214 for the moment.
      #   items       (Array)   = The individual line items for an order, using the following keys:
      #     line_num       (Integer) = The line number of the item on the order. (optional)
      #     product_id     (Integer) = Internal product id.
      #     product_name   (String)  = The name for the product_id associated with the item.
      #     category_id    (Integer) = Internal id for the (main) category associated with product.
      #     category_name  (String)  = The category name for the category id.
      #     qty            (Double)  = The quantity of items ordered.
      #     cost           (Double)  = The cost of a single item (Ex. Not the extended cost of the line).
      #
      # Returns:
      # True if successful, error code if not.
      #
      order = order.merge(:campaign_id => @campaign_id)
      call("campaignEcommAddOrder", order)
    end
    alias :ecomm_add_order :add_order
    
    def analytics
      # Retrieve the Google Analytics data we've collected for this campaign. Note, requires Google
      # Analytics Add-on to be installed and configured.
      #
      # Returns:
      # An array of analytics for the passed campaign including:
      #   visits            (Integer) = Number of visits.
      #   pages             (Integer) = Number of page views.
      #   new_visits        (Integer) = New visits recorded.
      #   bounces           (Integer) = Vistors who "bounced" from your site.
      #   time_on_site      (Double)  = 
      #   goal_conversions  (Integer) = Number of goals converted.
      #   goal_value        (Double)  = Value of conversion in dollars.
      #   revenue           (Double)  = Revenue generated by campaign.
      #   transactions      (Integer) = Number of transactions tracked.
      #   ecomm_conversions (Integer) = Number Ecommerce transactions tracked.
      #   goals             (Array)   = An array containing goal names and number of conversions.
      #
      call("campaignAnalytics", @campaign_id)
    end
    
    def bounce_messages(start = 0, limit = 25, since = "2000-01-01")
      # Retrieve the full bounce messages for the given campaign. Note that this can return very large amounts
      # of data depending on how large the campaign was and how much cruft the bounce provider returned. Also,
      # messages over 30 days old are subject to being removed.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 50.
      # since (Date)    = Pull only messages since this time - use YYYY-MM-DD format in GMT.
      #
      # Returns:
      # An array of full bounce messages for this campaign including:
      #   date    (String) = Date/time the bounce was received and processed.
      #   email   (String) = The email address that bounced.
      #   message (String) = The entire bounce message received.
      #
      call("campaignBounceMessages", @campaign_id, start, limit, since)
    end
    
    def click_details(url, start = 0, limit = 1000)
      # Return the list of email addresses that clicked on a given url, and how many times they clicked.
      # Note: Requires the AIM module to be installed.
      #
      # Parameters:
      # url   (String)  = The URL of the link that was clicked on.
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # An array of structs containing email addresses and click counts including:
      #   email   (String)  = Email address that opened the campaign.
      #   clicks  (Integer) = Total number of times the URL was clicked on by this email address.
      #
      call("campaignClickDetailAIM", @campaign_id, url, start, limit)
    end
    alias :click_detail_aim, :click_details
    
    def click_stats
      # Get an array of the urls being tracked, and their click counts for a given campaign.
      #
      # Returns:
      # A struct of URLs and associated statistics including:
      #   clicks (Integer) = Number of times the specific link was clicked.
      #   unique (Integer) = Number of unique people who clicked on the specific link.
      #
      call("campaignClickStats", @campaign_id)
    end
    
    def content(for_archive = true)
      # Get the content (both html and text) for a campaign either as it would appear in the campaign archive
      # or as the raw, original content.
      #
      # Parameters:
      # for_archive (Boolean) = Controls whether we return the Archive version (true) or the Raw version (false),
      #                         defaults to true.
      #
      # Returns:
      # A struct containing all content for the campaign including:
      #   html (String) = The HTML content used for the campgain with merge tags intact.
      #   text (String) = The Text content used for the campgain with merge tags intact.
      #
      call("campaignContent", @campaign_id, for_archive)
    end
    alias :campaign_content :content
    
    def delete
      # Delete a campaign.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("campaignDelete", @campaign_id)
    end
    alias :delete_campaign :delete
    
    def email_domain_performance
      # Get the top 5 performing email domains for this campaign.
      #
      # Returns:
      # An array of email domains and their associated stats including:
      #   domain      (String)  = Domain name or special "Other" to roll-up stats past 5 domains.
      #   total_sent  (Integer) = Total Email across all domains - this will be the same in every row.
      #   emails      (Integer) = Number of emails sent to this domain.
      #   bounces     (Integer) = Number of bounces.
      #   opens       (Integer) = Number of opens.
      #   clicks      (Integer) = Number of clicks.
      #   unsubs      (Integer) = Number of unsubscribes.
      #   delivered   (Integer) = Number of deliveries.
      #   emails_pct  (Integer) = Percentage of emails that went to this domain (whole number).
      #   bounces_pct (Integer) = Percentage of bounces from this domain (whole number).
      #   opens_pct   (Integer) = Percentage of opens from this domain (whole number).
      #   clicks_pct  (Integer) = Percentage of clicks from this domain (whole number).
      #   unsubs_pct  (Integer) = Percentage of unsubs from this domain (whole number).
      #
      call("campaignEmailDomainPerformance", @campaign_id)
    end
    alias :email_performance, :email_domain_performance
    
    def email_stats(email)
      # Given a campaign and email address, return the entire click and open history with timestamps, ordered by time.
      # Note: Requires the AIM module to be installed.
      #
      # Parameters:
      # email (String) = The email address to check OR the email "id" returned from listMemberInfo, Webhooks, and Campaigns.
      #
      # Returns:
      # An array of structs containing the actions including:
      #   action    (String)    = The action taken (open or click).
      #   timestamp (DateTime)  = Time the action occurred.
      #   url       (String)    = For clicks, the URL that was clicked.
      #
      call("campaignEmailStatsAIM", @campaign_id, email)
    end
    alias :email_stats_aim, :email_stats
    
    def email_stats_all(start = 0, limit = 100)
      # Given a campaign and correct paging limits, return the entire click and open history with timestamps, ordered by time,
      # for every user a campaign was delivered to.
      # Note: Requires the AIM module to be installed.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 1000.
      #
      # Returns:
      # An array of structs containing actions (opens and clicks) for each email, with timestamps including:
      #   action    (String)    = The action taken (open or click).
      #   timestamp (DateTime)  = Time the action occurred.
      #   url       (String)    = For clicks, the URL that was clicked.
      #
      call("campaignEmailStatsAIMAll", @campaign_id, start, limit)
    end
    alias :email_stats_aim_all, :email_stats_all
    
    def hard_bounces(start = 0, limit = 1000)
      # Get all email addresses with Hard Bounces for a given campaign.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # An array of email addresses with Hard Bounces.
      #
      call("campaignHardBounces", @campaign_id, start, limit)
    end
    
    def not_opened(start = 0, limit = 1000)
      # Retrieve the list of email addresses that did not open a given campaign.
      # Note: Requires the AIM module to be installed.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # A list of email addresses that did not open a campaign.
      #
      call("campaignNotOpenedAIM", @campaign_id, start, limit)
    end
    alias :not_opened_aim, :not_opened
    
    def opened(start = 0, limit = 1000)
      # Retrieve the list of email addresses that opened a given campaign with how many times they opened.
      # Note: this AIM function is free and does not actually require the AIM module to be installed.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # An array of structs containing email addresses and open counts including:
      #   email       (String)  = Email address that opened the campaign.
      #   open_count  (Integer) = Total number of times the campaign was opened by this email address.
      #
      call("campaignOpenedAIM", @campaign_id, start, limit)
    end
    alias :opened_aim, :opened
    
    def orders(start = 0, limit = 100, since = "2001-01-01 00:00:00")
      # Retrieve the Ecommerce Orders.
      #
      # Parameters:
      # start (Integer)   = For large data sets, the page number to start at.
      # limit (Integer)   = For large data sets, the number of results to return. Upper limit set at 500.
      # since (DateTime)  = Pull only messages since this time - use YYYY-MM-DD HH:II:SS format in GMT.
      #
      # Returns:
      # An array of orders and their details for this campaign, including:
      #   store_id    (String)  = The store id generated by the plugin used to uniquely identify a store.
      #   store_name  (String)  = The store name collected by the plugin - often the domain name.
      #   order_id    (Integer) = The internal order id the store tracked this order by.
      #   email       (String)  = The email address that received this campaign and is associated with this order.
      #   order_total (Double)  = The order total.
      #   tax_total   (Double)  = The total tax for the order (if collected).
      #   ship_total  (Double)  = The shipping total for the order (if collected).
      #   order_date  (String)  = The date the order was tracked - from the store if possible, otherwise the GMT time received.
      #   lines       (Array)   = Containing details of the order - product, category, quantity, item cost.
      #
      call("campaignEcommOrders", @campaign_id, start, limit, since)
    end
    alias :ecomm_orders, :orders
    
    def pause
      # Pause an AutoResponder orRSS campaign from sending.
      #
      # Returns:
      # True if successful.
      call("campaignPause", @campaign_id)
    end
    
    def replicate
      # Replicate a campaign.
      #
      # Returns:
      # The ID of the newly created replicated campaign. (String)
      #
      call("campaignReplicate", @campaign_id)
    end
    alias :replicate_campaign, :replicate
    
    def resume
      # Resume sending an AutoResponder or RSS campaign.
      #
      # Returns:
      # True if successful.
      #
      call("campaignResume", @campaign_id)
    end
    
    def schedule(time = "#{1.day.from_now}", time_b)
      # Schedule a campaign to be sent in the future.
      #
      # Parameters:
      # time    (DateTime) =  The time to schedule the campaign. For A/B Split "schedule" campaigns, the time
      #                       for Group A - in YYYY-MM-DD HH:II:SS format in GMT.
      # time_b  (DateTime) =  The time to schedule Group B of an A/B Split "schedule" campaign - in
      #                       YYYY-MM-DD HH:II:SS format in GMT. (optional)
      #
      # Returns:
      # True if successful.
      #
      call("campaignSchedule", @campaign_id, time, time_b)
    end
    alias :schedule_campaign, :schedule
    
    def send
      # Send this campaign immediately.
      #
      # Returns:
      # True if successful.
      call("campaignSendNow", @campaign_id)
    end
    alias :send_now, :send
    
    def send_test(emails = {}, send_type = nil)
      # Send a test of this campaign to the provided email address(es).
      #
      # Parameters:
      # emails    (Hash)    = A hash of email addresses to receive the test message.
      # send_type (String)  = One of 'html', 'text' or nil (send both). Defaults to nil.
      #
      # Returns:
      # True if successful.
      #
      call("campaignSendTest", @campaign_id, emails, send_type)
    end
    
    def share_report(options = {})
      # Get the URL to a customized VIP Report for the specified campaign and optionally send an email
      # to someone with links to it. Note subsequent calls will overwrite anything already set for the
      # same campign (eg, the password).
      #
      # Parameters:
      # options (Hash) = A hash of parameters which can be used to configure the shared report, including: (optional)
      #   header_type (String)  = One of "text" or "image". Defaults to 'text'. (optional)
      #   header_data (String)  = If "header_type" is text, the text to display. If "header_type" is "image"
      #                           a valid URL to an image file. Note that images will be resized to be no more
      #                           than 500x150. Defaults to the Accounts Company Name. (optional)
      #   secure      (Boolean) = Whether to require a password for the shared report. Defaults to "true". (optional)
      #   password    (String)  = If secure is true and a password is not included, we will generate one. It is always returned. (optional)
      #   to_email    (String)  = Email address to share the report with - no value means an email will not be sent. (optional)
      #   theme       (Array)   = An array containing either 3 or 6 character color code values for: "bg_color",
      #                           "header_color", "current_tab", "current_tab_text", "normal_tab", "normal_tab_text",
      #                           "hover_tab", "hover_tab_text". (optional)
      #   css_url     (String)  = A link to an external CSS file to be included after our default CSS
      #                           (http://vip-reports.net/css/vip.css) only if loaded via the "secure_url"
      #                           - max 255 characters. (optional)
      #
      # Returns:
      # A struct containing details for the shared report including:
      #   title       (String) = The Title of the Campaign being shared.
      #   url         (String) = The URL to the shared report.
      #   secure_url  (String) = The URL to the shared report, including the password (good for loading in an IFRAME).
      #                          For non-secure reports, this will not be returned.
      #   password    (String) = If secured, the password for the report, otherwise this field will not be returned.
      #
      call("campaignShareReport", @campaign_id, options)
    end
    
    def soft_bounces(start = 0, limit = 1000)
      # Get all email addresses with Soft Bounces for a given campaign.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # An array of email addresses with Soft Bounces.
      #
      call("campaignSoftBounces", @campaign_id, start, limit)
    end
    
    def stats
      # Get all the relevant campaign statistics for this campaign.
      #
      # Returns:
      # An array of statistics for this campaign including:
      #   syntax_error      (Integer) = Number of email addresses in campaign that had syntactical errors.
      #   hard_bounces      (Integer) = Number of email addresses in campaign that hard bounced.
      #   soft_bounces      (Integer) = Number of email addresses in campaign that soft bounced.
      #   unsubscribes      (Integer) = Number of email addresses in campaign that unsubscribed.
      #   abuse_reports     (Integer) = Number of email addresses in campaign that reported campaign for abuse.
      #   forwards          (Integer) = Number of times email was forwarded to a friend.
      #   forwards_opens    (Integer) = Number of times a forwarded email was opened.
      #   opens             (Integer) = Number of times the campaign was opened.
      #   last_open         (Date)    = Date of the last time the email was opened.
      #   unique_opens      (Integer) = Number of people who opened the campaign.
      #   clicks            (Integer) = Number of times a link in the campaign was clicked.
      #   unique_clicks     (Integer) = Number of unique recipient/click pairs for the campaign.
      #   last_click        (Date)    = Date of the last time a link in the email was clicked.
      #   users_who_clicked (Integer) = Number of unique recipients who clicked on a link in the campaign.
      #   emails_sent       (Integer) = Number of email addresses campaign was sent to.
      #
      call("campaignStats", @campaign_id)
    end
    alias :campaign_stats :stats
    
    def update(name, value)
      # Update just about any setting for a campaign that has not been sent.
      #
      # Parameters:
      # name  (String)    = The parameter name.
      # value (Variable)  = An appropriate value for the parameter.
      #
      # Returns:
      # True if successful, error code if not.
      #
      call("campaignUpdate", @campaign_id, name, value)
    end
    
    def unschedule
      # Unschedule a campaign that is scheduled to be sent in the future.
      #
      # Returns:
      # True if successful.
      #
      call("campaignUnschedule", @campaign_id)
    end
    
    def unsubsribes(start = 0, limit = 1000)
      # Get all unsubscribed email addresses for a given campaign.
      #
      # Parameters:
      # start (Integer) = For large data sets, the page number to start at.
      # limit (Integer) = For large data sets, the number of results to return. Upper limit set at 15000.
      #
      # Returns:
      # An array of email addresses that unsubscribed from this campaign.
      #
      call("campaignUnsubscribes", @campaign_id, start, limit)
    end
    
  end
end