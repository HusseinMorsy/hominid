require 'rake'
namespace :hominid do
  # Task to create the config file
  desc "Generate a Hominid config file"
  task :config => :environment do |t|
    require 'fileutils'
    if defined?(Rails.root)
      config_file = File.join(Rails.root, 'config', 'hominid.yml')
      template_file = File.join(File.dirname(__FILE__), '..', '..', 'hominid.yml.tpl')
      unless File.exists? config_file
        FileUtils.cp(
          File.join(File.dirname(__FILE__), '..', '..', 'hominid.yml.tpl'),
          File.join(Rails.root, 'config', 'hominid.yml')
        )
        puts 'Please edit config/hominid.yml to your needs.'
      else
        puts 'We left your existing config/hominid.yml untouched.'
      end
    end
  end
end

