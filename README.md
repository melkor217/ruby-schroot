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

     $ rake
     $ gem install ./*.gem
     
or just

     $ rake install
     
Examples
------
     
     irb(main):005:0> require 'schroot'
     => true
     irb(main):006:0> my_session = Schroot.new('sid')
     => #<Schroot:0x8ba789c @chroot="sid", @session="sid-19131ba0-84ba-42e5-a2fb-d2d375d61750", @location="/var/lib/schroot/mount/sid-19131ba0-84ba-42e5-a2fb-d2d375d61750">
     irb(main):007:0> stdin, stdout, stderr = my_session.run("echo Hello, World!")
     => [#<IO:fd 22>, #<IO:fd 24>, #<IO:fd 26>]
     irb(main):008:0> stdout.gets
     => "Hello, World!\n"
