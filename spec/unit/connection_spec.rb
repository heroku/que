# frozen_string_literal: true

require 'spec_helper'

describe Que_0_14_3 do
  it ".connection= with an unsupported connection should raise an error" do
    proc{Que_0_14_3.connection = "ferret"}.should raise_error RuntimeError, /Que_0_14_3 connection not recognized: "ferret"/
  end

  it ".adapter when no connection has been established should raise an error" do
    Que_0_14_3.connection = nil
    proc{Que_0_14_3.adapter}.should raise_error RuntimeError, /Que_0_14_3 connection not established!/
  end
end
