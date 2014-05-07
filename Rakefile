require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

task :build do
  system "gem build schroot.gemspec"
end

task :install => :build do
  system "sudo gem install schroot-*.gem"
end

task :default => :build