# frozen_string_literal: true

require 'spec_helper'

describe Que_0_14_3 do
  it ".use_prepared_statements should be the opposite of disable_prepared_statements" do
    original_verbose = $VERBOSE
    $VERBOSE = nil

    Que_0_14_3.use_prepared_statements.should == true
    Que_0_14_3.disable_prepared_statements.should == false

    Que_0_14_3.disable_prepared_statements = true
    Que_0_14_3.use_prepared_statements.should == false
    Que_0_14_3.disable_prepared_statements.should == true

    Que_0_14_3.disable_prepared_statements = nil
    Que_0_14_3.use_prepared_statements.should == true
    Que_0_14_3.disable_prepared_statements.should == false

    Que_0_14_3.use_prepared_statements = false
    Que_0_14_3.use_prepared_statements.should == false
    Que_0_14_3.disable_prepared_statements.should == true

    Que_0_14_3.use_prepared_statements = true
    Que_0_14_3.use_prepared_statements.should == true
    Que_0_14_3.disable_prepared_statements.should == false

    $VERBOSE = original_verbose
  end
end
