begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception => e
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => 'test'