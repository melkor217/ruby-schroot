require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

task :build => :test do
  system "gem build schroot.gemspec"
end

task :install => :build do
  system "sudo gem install schroot-0.0.1.gem"
end

task :default => :build