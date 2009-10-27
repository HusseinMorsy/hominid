require 'xmlrpc/client'
require 'ostruct'

module Hominid

  class HominidError < StandardError
    def initialize(error)
      super("#{error}")
    end
  end

  class HominidListError < HominidError
  end

  class HominidListEmailError < HominidListError
  end

  class HominidListMergeError < HominidListError
  end

  class AlreadySubscribed < HominidListEmailError
  end

  class AlreadyUnsubscribed < HominidListEmailError
  end

  class NotExists < HominidListEmailError
  end

  class NotSubscribed < HominidListEmailError
  end

  class HominidCommunicationError < HominidError
    def initialize(message)
      super(message)
    end
  end

end

begin
  # include the provided rake task
  require 'rake'
  unless Rake::Task.task_defined? "hominid:config"
    load File.join(File.dirname(__FILE__), '..', 'tasks', 'rails', 'hominid.rake')
  end
rescue LoadError
  # silently skip rake task inclusion unless the rake gem is installed
end

require 'hominid/base'

