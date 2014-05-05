require 'open3'

SCHROOT_BASE="/var/lib/schroot"

class SchrootError < StandardError
end

class Schroot
  def initialize(chroot_name = 'default')
    start(chroot_name)
  end

  def safe_run(cmd)
    stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
    if wait_thr.value != 0
      raise SchrootError, "\ncmd=\"%s\"\nreturn_code= %i\nstdout= \"%s\"" % [cmd, wait_thr.value, stdout.gets]
    end
    return stdin, stdout, stderr
  end

  def command(cmd, kwargs = {})
    command = ['schroot', '-r', '-c']
    if kwargs.has_key? :user
      command  << '-u'
      command << kwargs[:user]
    end
    if kwargs.has_key? :preserve_environment
      command << '-p'
    end
    command << '--'
    command << cmd
    return command
  end

  def run(cmd, kwargs = {})
    cmd_string = command(cmd,kwargs)
    # TBD
  end

  def clone
    return Schroot.new(@chroot)
  end

  def start(chroot_name = 'default')
    command = ['schroot', '-b', '-c', chroot_name]
    ObjectSpace.define_finalizer(self, proc { stop })
    stdin, stdout, stderr = safe_run("schroot -b -c %s" % chroot_name)
    @chroot = chroot_name
    @session = stdout.gets.strip
    stdin, stdout, stderr = safe_run("schroot --location -c session:%s" % @session)
    @location = stdout.gets.strip
  end

  def stop
    stdin, stdout, stderr = safe_run("schroot -e -c %s" % @session)
    @session = nil
    @location = nil
  end

  private :safe_run, :command
  attr_reader :session, :location, :chroot
end