require 'test/unit'
require 'aiml/utils'

class TestFacade < Test::Unit::TestCase
  def setup
    @robot = AIML::Facade.new
    @robot.learn('test/data/facade.aiml')
  end

  def test_aiml_file_finder
    actual = AIML::AimlFinder::find(['test/data/mixed/single.aiml',
                                        'test/data/mixed/dir']).sort
    expected = ['test/data/mixed/single.aiml',
                'test/data/mixed/dir/in_dir.aiml',
                'test/data/mixed/dir/subdir/in_sub_dir.aiml'].sort
    assert_equal(expected, actual)
  end
end
