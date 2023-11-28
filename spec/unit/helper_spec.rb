# frozen_string_literal: true

require 'spec_helper'

describe Que_0_14_3, 'helpers' do
  it "should be able to clear the jobs table" do
    DB[:que_jobs_0_14_3].insert :job_class => "Que_0_14_3::Job"
    DB[:que_jobs_0_14_3].count.should be 1
    Que_0_14_3.clear!
    DB[:que_jobs_0_14_3].count.should be 0
  end
end
