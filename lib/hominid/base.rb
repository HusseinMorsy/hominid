module Hominid
  class Base

    # MailChimp API Documentation: http://www.mailchimp.com/api/1.2/
    MAILCHIMP_API = "http://api.mailchimp.com/1.2/"

    def initialize(config = {})
      if defined?(Rails.root) && (!config || config.empty?)
        config = YAML.load(File.open("#{Rails.root}/config/hominid.yml"))[Rails.env].symbolize_keys
      end
      config.merge(:username => config[:username].to_s, :password => config[:password].to_s)
      defaults = {:send_welcome       => false,
                  :double_opt_in      => false,
                  :update_existing    => true,
                  :replace_interests  => true,
                  :merge_tags         => {}}
      @config = defaults.merge(config).freeze
      @chimpApi = XMLRPC::Client.new2(MAILCHIMP_API)
    end
    
    # Security related methods
    # --------------------------------
    
    def add_api_key
      @chimpApi.call("apikeyAdd", *@config.values_at(:username, :password, :api_key))
    end

    def expire_api_key
      @chimpApi.call("apikeyExpire", *@config.values_at(:username, :password, :api_key))
    end

    def api_keys(include_expired = false)
      username, password = *@config.values_at(:username, :password)
      @chimpApi.call("apikeys", username, password, include_expired)
    end
    
    # Campaign related methods
    # --------------------------------
    
    def create_campaign(type = 'regular', options = {}, content = {}, segment_options = {}, type_opts = {})
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
      call("campaignCreate", type, options, content, segment_options, type_opts)
    end

    def campaigns(filters = {}, start = 0, limit = 50)
      # Get the campaigns for this account
      # API Version 1.2 requires that filters be sent as a hash
      # Available options for the filters hash are:
      #
      #   :campaign_id    = (string)  The ID of the campaign you wish to return.
      #   :list_id        = (string)  Show only campaigns with this list_id.
      #   :folder_id      = (integer) Show only campaigns from this folder.
      #   :from_name      = (string)  Show only campaigns with this from_name.
      #   :from_email     = (string)  Show only campaigns with this from_email.
      #   :title          = (string)  Show only campaigns with this title.
      #   :subject        = (string)  Show only campaigns with this subject.
      #   :sedtime_start  = (string)  Show campaigns sent after YYYY-MM-DD HH:mm:ss.
      #   :sendtime_end   = (string)  Show campaigns sent before YYYY-MM-DD HH:mm:ss.
      #   :subject        = (boolean) Filter by exact values, or search within content for filter values.
      call("campaigns", filters, start, limit)
    end

    def campaign_ecomm_add_order(order)
      # Attach Ecommerce Order Information to a Campaign.
      # The order hash should be structured as follows:
      #
      #   :id             = (string)  the order id
      #   :campaign_id    = (string)  the campaign id to track the order (mc_cid query string).
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
      call("campaignEcommAddOrder", order)
    end
    
    def templates
      # Get the templates
      call("campaignTemplates")
    end
    
    # Helper methods
    # --------------------------------
    
    def html_to_text(content)
      # Convert HTML content to text
      call("generateText", 'html', content)
    end

    def convert_css_to_inline(html, strip_css = false)
      # Convert CSS styles to inline styles and (optionally) remove original styles
      call("inlineCss", html, strip_css)
    end
    
    # Used internally by Hominid
    # --------------------------------

    def apply_defaults_to(options)
      @config.merge(options)
    end

    def call(method, *args)
      @chimpApi.call(method, @config[:api_key], *args)
    rescue XMLRPC::FaultException => error
      case error.faultCode
      when 230
        raise AlreadySubscribed.new(error)
      when 231
        raise AlreadyUnsubscribed.new(error)
      when 232
        raise NotExists.new(error)
      when 233, 215
        raise NotSubscribed.new(error)
      else
        raise HominidError.new(error)
      end

    rescue Exception => error
      raise HominidCommunicationError.new(error.message)
    end
  end
end
    
    
    