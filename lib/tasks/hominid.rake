require 'ftools'

namespace :hominid do
  # Task to create the config file
  desc "Generate a Hominid config file"
  task :config => :environment do |t|
    if defined?(Rails.root)
      File.copy("hominid.yml.tpl", "#{Rails.root}/config/hominid.yml")
    end
  end
end