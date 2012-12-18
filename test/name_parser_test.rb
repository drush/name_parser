require 'test_helper'

class NameParserTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, NameParser
  end

  test 'Simple AR Model' do
  # class Person #< ActiveModel::Base
  #   include ActiveModel::Serialization
  #   extend NameParser  
  # end
  end

end
