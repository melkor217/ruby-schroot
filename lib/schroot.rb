require 'open3'

class SchrootError < StandardError
end

class Schroot
  def self.hi
    return "Hello world!"
  end
  
  def safe_run(cmd)
    stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
    if wait_thr.value != 0
      raise SchrootError, "\ncmd=\"%s\"\nreturn_code= %i\nstdout= \"%s\"" % [cmd, wait_thr.value, stdout.gets] 
    end
    return stdin, stdout, stderr
  end
  
  def command(cmd, kwargs)
    command = ['schroot', '-r', '-c']
    command.push '--'
    command.push cmd
  end
  
  def start(chroot_name)
    command = ['schroot', '-b', '-c', chroot_name]
    stdin, stdout, stderr = safe_run("schroot -b -c %s" % chroot_name)
    @session = stdout.gets.strip
    stdin, stdout, stderr = safe_run("schroot --location -c session:%s" % @session)
    @location = stdout.gets.strip
    
  end
  
  def end
    stdin, stdout, stderr = safe_run("schroot -e -c %s" % @session)
  end
  
  private :safe_run
  attr_reader :session, :location
end