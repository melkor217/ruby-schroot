require 'open3'

class Schroot
  def self.hi
    return "Hello world!"
  end
  
  def command(cmd, kwargs)
    command = ['schroot', '-r', '-c']
    command.push '--'
    command.push cmd
  end
  
  def start(chroot_name)
    command = ['schroot', '-b', '-c', chroot_name]
    stdin, stdout, stderr = Open3.popen3(command.join(" "))
    @session = stdout.gets.strip
    print "\n"+@session+"\n"
  end
end