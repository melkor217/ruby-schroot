require 'test/unit'
require 'schroot'

class SchrootTest < Test::Unit::TestCase
  #  def test_hello
  #    assert_equal "Hello world!",
  #      Schroot.hi
  #  end
  def test_start
    test = Schroot.new('default')
    print_debug(test,:test)

    assert_not_nil test.session
    assert_not_nil test.chroot
    assert_not_nil test.location

    test_clone = test.clone
    print_debug(test_clone,:test_clone)

    assert_not_nil test_clone.session
    assert_not_nil test_clone.chroot
    assert_not_nil test_clone.location

    assert_not_equal test.session, test_clone.session
    assert_not_equal test.session, test_clone.location
    assert_equal test.chroot, test_clone.chroot

    test.stop
    print_debug(test,:stopped)

    test = Schroot.new
    assert_equal test.run("echo -n 123")[1].gets, "123"
    assert_equal test.run("echo 123")[1].gets, "123\n"
  end

  def print_debug(schroot,name = 'chroot')
    print "\n#{name}_session = %s\n" % schroot.session
    print "#{name}_chroot = %s\n" % schroot.chroot
    print "#{name}_location = %s\n" % schroot.location
  end
end