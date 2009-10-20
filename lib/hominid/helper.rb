module Hominid

  class Helper < Base
    
    # Helper methods
    # --------------------------------
    
    def self.account_details
      # Get details for this account.
      new.call("getAccountDetails")
    end
    
    def self.convert_css_to_inline(html, strip_css = false)
      # Convert CSS styles to inline styles and (optionally) remove original styles
      new.call("inlineCss", html, strip_css)
    end
    
    def self.create_folder(name)
      # Create a new folder to file campaigns in
      new.call("createFolder", name)
    end
    
    def self.generate_text(type, content)
      # Have HTML content auto-converted to a text-only format.
      # The options for text type are:
      #   'html'      => Expects a string of HTML(default).
      #   'template'  => Expects an array.
      #   'url'       => Expects a valid and public URL.
      #   'cid'       => Expects a campaign ID.
      #   'tid'       => Expects a template ID.
      new.call("generateText", type, content)
    end
    
    def self.html_to_text(content)
      # Convert HTML content to text
      new.call("generateText", 'html', content)
    end
    
    def self.ping
      # Ping the Mailchimp API
      new.call("ping")
    end
    
  end
end