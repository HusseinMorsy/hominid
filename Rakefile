require 'rake'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "hominid"
    s.summary = "Hominid is a Rails GemPlugin for interacting with the Mailchimp API"
    s.email = "brian@terra-firma-design.com"
    s.homepage = "http://github.com/bgetting/hominid"
    s.description = "Hominid is a Rails GemPlugin for interacting with the Mailchimp API"
    s.authors = ["Brian Getting"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Generate documentation for the hominid plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hominid'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
