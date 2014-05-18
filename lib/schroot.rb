require 'open3'
require 'logger'

module Schroot

  SCHROOT_BASE='/var/lib/schroot'
  BASE_CONF='/etc/schroot/schroot.conf'
  CONF_D='/etc/schroot/chroot.d/'
  CONF_D_PREFIX='99ruby-'

  class SchrootError < StandardError
  end

  # @return [Hash] representation of current config fules
  def self.readconf
    chroots = {}
    files = [BASE_CONF]
    Dir.entries(CONF_D).each do |file|
      files << (CONF_D+CONF_D_PREFIX+file) unless %w(. ..).include? file
    end
    files.each do |file|
      stream = File.open(file, 'r')
      current = nil
      while line = stream.gets
        if match_name(line)
          current = match_name(line)[1]
          chroots[current.strip] = {:source => file}
        elsif current and match_param(line)
          param, value = match_param(line)[1], match_param(line)[2]
          chroots[current][param.strip] = value.strip if current
        end
      end
      stream.close
    end
    return chroots
  end

  def self.match_name(name)
    return /^\s*\[([a-z0-9A-Z\-\_]+)\]/.match(name)
  end

  def self.match_param(param)
    return /^\s*([a-z0-9A-Z\-\_]+)\=(.*)$/.match(param)
  end

  # Adds new chroot configuration to .../chroot.d/ directory
  #
  # @example
  #   SchrootConfig.add("testing", {"description" => "Debian testing",
  #                                 "file"        => "/srv/chroot/testing.tgz",
  #                                 "location"    => "/testing",
  #                                 "groups"      => "sbuild"})
  #   => true
  # @param name [String] name of chroot
  # @param kwargs [Hash] options
  # @param force [Bool] should we override existing config
  # @return [Bool] true if operation has completed successfully
  def self.add(name, kwargs = {}, force=false)
    chroots = readconf
    filename = CONF_D+CONF_D_PREFIX+name
    if (chroots[name] or File.exists?(filename)) and !force
      return false
    else
      begin
        stream = File.open(filename, "w")
      rescue Errno::EACCES
        raise SchrootError, "Cannot open #{filename} for writing"
      end
      stream.puts '# Generated automatically with ruby-schroot'
      stream.puts "[#{name}]"
      kwargs.each do |param, value|
        stream.puts "#{param}=#{value}"
      end
      stream.close
    end
    return true
  end

  # Removes chroot from .../chroot.d/ directory
  #
  # @example
  #   SchrootConfig.remove("testing", true)
  #     => true
  # @param name [String] name of chroot
  # @param kwargs [Hash] options
  # @param force [Bool] should we override existing config
  # @return [Bool] true if operation has completed successfully
  def self.remove(name, force=false)
    chroots = readconf
    filename = CONF_D+CONF_D_PREFIX+name
    if (File.exists?(filename) and chroots[name]) or force
      File.delete(filename)
      return true
    else
      return false
    end
  end


# Schroot session handler
  class Chroot
    def initialize(chroot_name = 'default', &block)
      @logger = Logger.new nil

      if block_given?
        if block.arity == 1
          yield self
        elsif block.arity == 0
          instance_eval &block
        end
      end

      start(chroot_name)
    end

    def safe_run(cmd)
      @logger.info("Executing %s" % cmd)
      begin
        stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
      rescue Errno::ENOENT
        raise SchrootError, 'Schroot binary is missing!'
      end
      if wait_thr.value != 0
        raise SchrootError, '`%s` execution failed with %i' % [cmd, wait_thr.value]
      end
      @logger.info("Done!")
      return stdin, stdout, stderr, wait_thr
    end

    def command(cmd, kwargs = {})
      raise SchrootError, 'No current session' unless @session
      command = ['schroot', '-r', '-c', @session]
      if kwargs.has_key? :user
        command << '-u'
        command << kwargs[:user]
      end
      if kwargs.has_key? :preserve_environment
        command << '-p'
      end
      command << '--'
      command << cmd
      command.join(' ')
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
      safe_run(command(cmd, kwargs))
    end

    # Clones current session
    #
    # @return [Object] new session object
    def clone
      Chroot.new(@chroot)
    end

    # Starts the session of `chroot_name` chroot
    #
    # @param chroot_name [String] name of configured chroot
    # @return [String] schroot session id
    # A string representing schroot session id.
    def start(chroot_name = 'default')
      @logger.debug('Starting chroot session')
      stop if @session
      ObjectSpace.define_finalizer(self, proc { stop })
      state = safe_run('schroot -b -c %s' % chroot_name)
      @chroot = chroot_name
      @session = state[1].gets.strip
      state = safe_run('schroot --location -c session:%s' % @session)
      @location = state[1].gets.strip
      @logger.debug('Session %s with %s started in %s' % [@session, @chroot, @location])
      @session
    end

    # Stops current chroot session.
    #
    # @return [nil] session_id of killed session (should be nil)
    def stop
      @logger.debug('Stopping session %s with %s' % [@session, @chroot])
      safe_run("schroot -e -c %s" % @session)
      @logger.debug('Session %s of %s should be stopped' % [@session, @chroot])
      @location = nil
      @session = nil

    end

    # Sets log object
    def log(log=@logger)
      @logger = log
      @logger.debug('Hello there!')
    end

    private :safe_run, :command
    attr_reader :session, :location, :chroot, :logger
  end

end