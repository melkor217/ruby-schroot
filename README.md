ruby-schroot
============

Ruby bindings for debian schroot

What is it?
--------
It's a gem which allows to create `schroot` sessions and execute commands in the chroot environment from ruby code.
Currently it just calls schroot binaries.
Ability to manage chroots (eg create) is coming soon.

Usage
-------
Library requires installed chroot binary. All chroots u want to use should be configured in `/etc/schroot/schroot.conf` or `/etc/schroot/conf.d/`.

Little example:

    [sid]
    type=directory
    description=Debian sid (unstable)
    union-type=aufs
    directory=/srv/chroot/sid
    users=dan
    groups=dan
    root-groups=root
    aliases=unstable,default

Library installation is pretty simple:

```bash
$ rake
$ gem install ./*.gem
```
     
or just
```bash
$ rake install
```  
Examples
------

Simple example:
     
```ruby
  irb(main):005:0> require 'schroot'
  => true
  irb(main):006:0> my_session = Schroot.new('sid')
  => #<Schroot:0x8ba789c @chroot="sid", @session="sid-19131ba0-84ba-42e5-a2fb-d2d375d61750", @location="/var/lib/schroot/mount/sid-19131ba0-84ba-42e5-a2fb-d2d375d61750">
  irb(main):007:0> stdin, stdout, stderr = my_session.run("echo Hello, World!")
  => [#<IO:fd 22>, #<IO:fd 24>, #<IO:fd 26>]
  irb(main):008:0> stdout.gets
  => "Hello, World!\n"
```
Using logger:
```ruby
  irb(main):001:0> require 'schroot'
  => true
  irb(main):002:0> my_logger = Logger.new(STDOUT)
  => #<Logger:0x0000000199b460 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x0000000199b438 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x0000000199b3c0 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x0000000199b370 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x0000000199b2f8>>>>
  irb(main):003:0> session = Schroot.new('default') do
  irb(main):004:1*   log my_logger
  irb(main):005:1> end
  D, [2014-05-06T19:49:15.497952 #3084] DEBUG -- : Hello there!
  D, [2014-05-06T19:49:15.498035 #3084] DEBUG -- : Starting chroot session
  I, [2014-05-06T19:49:15.498069 #3084]  INFO -- : Executing schroot -b -c default
  I, [2014-05-06T19:49:15.584809 #3084]  INFO -- : Done!
  I, [2014-05-06T19:49:15.584939 #3084]  INFO -- : Executing schroot --location -c session:sid-7cefa94f-4bea-4d30-b4a9-d3008c255360
  I, [2014-05-06T19:49:15.591380 #3084]  INFO -- : Done!
  D, [2014-05-06T19:49:15.591504 #3084] DEBUG -- : Session sid-7cefa94f-4bea-4d30-b4a9-d3008c255360 with default started in /var/lib/schroot/mount/sid-7cefa94f-4bea-4d30-b4a9-d3008c255360
  => #<Schroot:0x000000019acda0 @logger=#<Logger:0x0000000199b460 @progname=nil, @level=0, @default_formatter=#<Logger::Formatter:0x0000000199b438 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x0000000199b3c0 @shift_size=nil, @shift_age=nil, @filename=nil, @dev=#<IO:<STDOUT>>, @mutex=#<Logger::LogDevice::LogDeviceMutex:0x0000000199b370 @mon_owner=nil, @mon_count=0, @mon_mutex=#<Mutex:0x0000000199b2f8>>>>, @chroot="default", @session="sid-7cefa94f-4bea-4d30-b4a9-d3008c255360", @location="/var/lib/schroot/mount/sid-7cefa94f-4bea-4d30-b4a9-d3008c255360">
  irb(main):006:0> stream = session.run('uname -a')
  I, [2014-05-06T19:50:35.057816 #3084]  INFO -- : Executing schroot -r -c sid-7cefa94f-4bea-4d30-b4a9-d3008c255360 -- uname -a
  I, [2014-05-06T19:50:35.251893 #3084]  INFO -- : Done!
  => [#<IO:fd 13>, #<IO:fd 15>, #<IO:fd 17>]
  irb(main):007:0> stream[1].gets
  => "Linux dan-desktop 3.13-1-amd64 #1 SMP Debian 3.13.7-1 (2014-03-25) x86_64 GNU/Linux\n"
```

