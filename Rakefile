require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  # Put spec opts in a file named .rspec in root
end


# I plan to release this publicly.  Before then, though, it'll also be
# useful to do some internal releases.  The following rakefile is
# .gitignore'd so that it details about our internal gem server don't
# get leaked into a public repo.  (This level of paranoia is probably
# excessive, but I'm doing it anyway...)
Rake.load_rakefile 'private_tasks.rake'
