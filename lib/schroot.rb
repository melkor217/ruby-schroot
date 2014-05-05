require 'open3'

SCHROOT_BASE="/var/lib/schroot"

class SchrootError < StandardError
end

# Schroot session handler
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
    raise SchrootError, "No current session" unless @session
    command = ['schroot', '-r', '-c', @session]
    if kwargs.has_key? :user
      command  << '-u'
      command << kwargs[:user]
    end
    if kwargs.has_key? :preserve_environment
      command << '-p'
    end
    command << '--'
    command << cmd
    return command.join(" ")
  end

  # Runs command inside of chroot session.
  # Session must be started before.
  #
  # @example
  #   session.run("ping localhost",{:user => 'rainbowdash',:preserve_environment => true})
  #     => [#<IO:fd 16>, #<IO:fd 18>, #<IO:fd 20>]
  # @param cmd [String] command to run
  # @param kwargs [Hash] extra args
  # @return [Array<(IO:fd, IO:fd, IO:fd)>] descriptors for stdin, stdout, stderr
  def run(cmd, kwargs = {})
    return safe_run(command(cmd,kwargs))
  end

  # Clones current session
  #
  # @return [Object] new session object
  def clone
    return Schroot.new(@chroot)
  end

  # Starts the session of `chroot_name` chroot
  #
  # @param chroot_name [String] name of configured chroot
  # @return [String] schroot session id
  # A string representing schroot session id.
  def start(chroot_name = 'default')
    stop if @session
    command = ['schroot', '-b', '-c', chroot_name]
    ObjectSpace.define_finalizer(self, proc { stop })
    stdin, stdout, stderr = safe_run("schroot -b -c %s" % chroot_name)
    @chroot = chroot_name
    @session = stdout.gets.strip
    stdin, stdout, stderr = safe_run("schroot --location -c session:%s" % @session)
    @location = stdout.gets.strip
    return @session
  end

  # Stops current chroot session.
  #
  # @param chroot_name [String] name of configured chroot
  # @return [nil] session_id of killed session (should be nil)
  def stop
    stdin, stdout, stderr = safe_run("schroot -e -c %s" % @session)
    @location = nil
    @session = nil
  end

  private :safe_run, :command
  attr_reader :session, :location, :chroot
end