module Hominid
  
  class Campaign < Base
    
    # Campaign related methods
    # --------------------------------

    attr_reader :campaign_id
    
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.last : {}
      raise HominidError.new('Please provide a Campaign ID.') unless options[:id]
      @campaign_id = options.delete(:id)
      super(options)
    end

    def campaign_stats()
      # Get the stats of a campaign
      call("campaignStats", @campaign_id)
    end

    def campaign_content()
      # Get the content of a campaign
      call("campaignContent", @campaign_id)
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

