# frozen_string_literal: true

# Common Job classes for use in specs.

# Handy for blocking in the middle of processing a job.
class BlockJob < Que_0_14_3::Job
  def run
    $q1.push nil
    $q2.pop
  end
end

RSpec.configure do |config|
  config.before { $q1, $q2 = Queue.new, Queue.new }
end



class ErrorJob < Que_0_14_3::Job
  def run
    raise "ErrorJob!"
  end
end



class ArgsJob < Que_0_14_3::Job
  def run(*args)
    $passed_args = args
  end
end

RSpec.configure do |config|
  config.before { $passed_args = nil }
end
