require 'test/unit'
require 'schroot'

class SchrootTest < Test::Unit::TestCase
  #  def test_hello
  #    assert_equal "Hello world!",
  #      Schroot.hi
  #  end
  def test_start
    test = Schroot.new 'sid'
    print_debug(test,:test)

    test_clone = test.clone
    print_debug(test_clone,:clone)

    test_dup = test.dup
    print_debug(test_clone,:dup)

    test.stop
    print_debug(test,:stopped)
  end

  def print_debug(schroot,name = 'chroot')
    print "\n#{name}_session = %s\n" % schroot.session
    print "#{name}_chroot = %s\n" % schroot.chroot
    print "#{name}_location = %s\n" % schroot.location
  end
end