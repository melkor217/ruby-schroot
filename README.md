# Schroot [![Gem Version](https://badge.fury.io/rb/schroot.png)](http://badge.fury.io/rb/schroot) 

Schroot gem allows to create `schroot` sessions and execute commands in the chroot environment from ruby code.

Currently it just calls schroot binaries.

Ability to manage chroots (eg create) is coming soon.

## Installation

Add this line to your application's Gemfile:

    gem 'schroot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install schroot

## Usage

Simple example:
     
```ruby
>> require 'schroot'
=> true
>> session = Schroot::Chroot.new('sid')
=> #<Schroot::Chroot:0x82858b8 @logger=#<Logger:0x8285890 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x828587c @datetime_format=nil>, formatternil, logdevnil, session"sid-8861c7e6-2339-47b3-bdf5-d79435cefea2", chroot"sid", location"/var/lib/schroot/mount/sid-8861c7e6-2339-47b3-bdf5-d79435cefea2"
>> session.run("uname -a",
?>             :user => 'rainbowdash',
?>             :preserve_environment => true) do |stdin, stdout, stderr, wait_thr|
?>   puts wait_thr.pid, wait_thr.value, stdout.read
>> end
30983
pid 30983 exit 0
Linux dan-desktop 3.14-1-686-pae #1 SMP Debian 3.14.2-1 (2014-04-28) i686 GNU/Linux
=> nil

```
Using logger:

```ruby
>> require 'schroot'
=> true
>> session = Schroot::Chroot.new('sid') do
?> log Logger.new(STDOUT)
>> end
D, [2014-05-20T02:06:06.278458 #32663] DEBUG -- : Hello there!
D, [2014-05-20T02:06:06.278572 #32663] DEBUG -- : Starting chroot session
I, [2014-05-20T02:06:06.278632 #32663]  INFO -- : Executing schroot -b -c sid
I, [2014-05-20T02:06:06.454060 #32663]  INFO -- : Done!
I, [2014-05-20T02:06:06.454199 #32663]  INFO -- : Executing schroot --location -c session:sid-0a254101-12c2-44d6-a1b8-60a88e81b427
I, [2014-05-20T02:06:06.465670 #32663]  INFO -- : Done!
D, [2014-05-20T02:06:06.465802 #32663] DEBUG -- : Session sid-0a254101-12c2-44d6-a1b8-60a88e81b427 with sid started in /var/lib/schroot/mount/sid-0a254101-12c2-44d6-a1b8-60a88e81b427
=> #<Schroot::Chroot:0x924f85c @logger=#<Logger:0x924f640 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x924f62c @datetime_format=nil>, formatternil, logdev#<Logger::LogDevice:0x924f604 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>, mutex#<Logger::LogDevice::LogDeviceMutex:0x924f5f0 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x924f5c8>, session"sid-0a254101-12c2-44d6-a1b8-60a88e81b427", chroot"sid", location"/var/lib/schroot/mount/sid-0a254101-12c2-44d6-a1b8-60a88e81b427"
>> session.run("whoami") { |stdin, stdout| puts stdout.read }
I, [2014-05-20T02:06:16.607930 #32663]  INFO -- : Executing schroot -r -c sid-0a254101-12c2-44d6-a1b8-60a88e81b427 -- whoami
dan
I, [2014-05-20T02:06:16.677187 #32663]  INFO -- : Done!
=> #<Process::Status: pid 329 exit 0>
>> session.stop
D, [2014-05-20T02:06:35.798690 #32663] DEBUG -- : Stopping session sid-0a254101-12c2-44d6-a1b8-60a88e81b427 with sid
I, [2014-05-20T02:06:35.798781 #32663]  INFO -- : Executing schroot -e -c sid-0a254101-12c2-44d6-a1b8-60a88e81b427
I, [2014-05-20T02:06:36.021379 #32663]  INFO -- : Done!
D, [2014-05-20T02:06:36.021518 #32663] DEBUG -- : Session sid-0a254101-12c2-44d6-a1b8-60a88e81b427 of sid should be stopped
=> nil
```

## Contributing

1. Fork it ( https://github.com/melkor217/ruby-schroot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
