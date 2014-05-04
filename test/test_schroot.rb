require 'test/unit'
require 'schroot'

class SchrootTest < Test::Unit::TestCase
  def test_english_hello
    assert_equal "Hello world!",
      Schroot.hi
  end

  def test_any_hello
    assert_equal "Hello world!",
      Schroot.hi
  end

  def test_spanish_hello
    assert_equal "Hello world!",
      Schroot.hi
  end
  
  def test_start
    test = Schroot.new
    test.start('sid')
  end
end