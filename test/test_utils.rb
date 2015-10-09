require 'pry'
require 'pry-nav'
require 'minitest/autorun'
require 'date'
require_relative '../lib/aiml_engine'

describe "utilities" do

  it "finds AIML files" do
    actual = AIML::FileFinder::find_aiml(['test/data/mixed/single.aiml',
                                        'test/data/mixed/dir']).sort
    expected = ['test/data/mixed/single.aiml',
                'test/data/mixed/dir/in_dir.aiml',
                'test/data/mixed/dir/subdir/in_sub_dir.aiml'].sort
    assert_equal(expected, actual)
  end

  it "finds Rosie's AIML files" do
    actual = AIML::FileFinder::find_aiml('test/data/rosie').sort

    expected = [
        'test/data/rosie/aiml/animal.aiml',
        'test/data/rosie/aiml/bot_profile.aiml',
        'test/data/rosie/aiml/client_profile.aiml',
        'test/data/rosie/aiml/config.aiml',
        'test/data/rosie/aiml/date.aiml',
        'test/data/rosie/aiml/default.aiml',
        'test/data/rosie/aiml/dialog.aiml',
        'test/data/rosie/aiml/inappropriate.aiml',
        'test/data/rosie/aiml/inquiry.aiml',
        'test/data/rosie/aiml/insults.aiml',
        'test/data/rosie/aiml/knowledge.aiml',
        'test/data/rosie/aiml/personality.aiml',
        'test/data/rosie/aiml/profanity.aiml',
        'test/data/rosie/aiml/reductions1.aiml',
        'test/data/rosie/aiml/reductions2.aiml',
        'test/data/rosie/aiml/reductions_update.aiml',
        'test/data/rosie/aiml/roman.aiml',
        'test/data/rosie/aiml/that.aiml',
        'test/data/rosie/aiml/train.aiml',
        'test/data/rosie/aiml/udc.aiml',
        'test/data/rosie/aiml/utilities.aiml',
        'test/data/rosie/aiml/z_update.aiml'
    ]

    assert_equal(expected, actual)
  end
end
