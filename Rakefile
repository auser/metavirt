require 'rubygems' 
# require 'micronaut/rake_task'
require 'rake/testtask'

# desc "Run all micronaut examples"
# Micronaut::RakeTask.new :examples do |t|
#   t.pattern = "examples/**/*_example.rb"
# end

# desc "Run all micronaut examples using rcov"
# Micronaut::RakeTask.new :coverage do |t|
#   t.pattern = "test/**/*_example.rb"
#   # t.rcov = true
#   # t.rcov_opts = "--exclude \"examples/*,gems/*,db/*,/Library/Ruby/*,config/*\" --text-summary  --sort coverage --no-validator-links" 
# end

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
  t.verbose = true
end
task :default => :test

namespace(:db) do
  desc "Clear the db"
  task :clear do
    dbfile = File.join(File.dirname(__FILE__), "db", "metavirt.db")
    File.delete(dbfile) if File.file?(dbfile)
  end
  desc "Migrate the db"
  task :migrate do
    `sequel sqlite://db/metavirt.db -m db/migrations`
  end
  desc "Reset, clear and migrate the db"
  task :reset => [:clear, :migrate]
end

desc "Start the server"
task :start do
  `thin start -R config.ru`
end

namespace :dev do
  desc "Reset database and start"
  task :go => ["db:reset", :start]
end