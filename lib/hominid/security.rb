module Hominid
  class Security < Base
    
    # SECURITY RELATED METHODS
    
    attr_reader :username
    attr_reader :password

    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise StandardError.new('Please provide your Mailchimp account username.') unless options[:username]
      raise StandardError.new('Please provide your Mailchimp account password.') unless options[:password]
      @username = options.delete(:username)
      @password = options.delete(:password)
      super(options)
    end
    
    # Security Methods
    
    def add_api_key
      # Add an API Key to your account. We will generate a new key for you and return it.
      #
      # Returns:
      # A new API Key that can be immediately used.
      #
      @chimpApi.call("apikeyAdd", @username, @password, @config[:api_key])
    end
    
    def api_keys(expired = false)
      # Retrieve a list of all MailChimp API Keys for this User.
      #
      # Parameters:
      # expired (Boolean) = Whether or not to include expired keys, defaults to false.
      #
      # Returns:
      # An array of API keys including:
      #   apikey      (String) = The api key that can be used.
      #   created_at  (String) = The date the key was created.
      #   expired_at  (String) = The date the key was expired.
      #
      @chimpApi.call("apikeys", @username, @password, @config[:api_key], expired)
    end
    
    def expire_api_key
      # Expire a Specific API Key.
      #
      # Returns:
      # True if successful, error code if not.
      #
      @chimpApi.call("apikeyExpire", @username, @password, @config[:api_key])
    end
    
  end
end