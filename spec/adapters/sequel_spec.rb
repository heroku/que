# frozen_string_literal: true

require 'spec_helper'

Que_0_14_3.connection = SEQUEL_ADAPTER_DB = Sequel.connect(QUE_URL)
QUE_ADAPTERS[:sequel] = Que_0_14_3.adapter

describe "Que_0_14_3 using the Sequel adapter" do
  before { Que_0_14_3.adapter = QUE_ADAPTERS[:sequel] }

  it_behaves_like "a multi-threaded Que_0_14_3 adapter"

  it "should use the same connection that Sequel does" do
    begin
      class SequelJob < Que_0_14_3::Job
        def run
          $pid1 = Integer(Que_0_14_3.execute("select pg_backend_pid()").first['pg_backend_pid'])
          $pid2 = Integer(SEQUEL_ADAPTER_DB['select pg_backend_pid()'].get)
        end
      end

      SequelJob.enqueue
      Que_0_14_3::Job.work

      $pid1.should == $pid2
    ensure
      $pid1 = $pid2 = nil
    end
  end

  it "should wake up a Worker after queueing a job in async mode, waiting for a transaction to commit if necessary" do
    Que_0_14_3.mode = :async
    Que_0_14_3.worker_count = 4
    sleep_until { Que_0_14_3::Worker.workers.all? &:sleeping? }

    # Wakes a worker immediately when not in a transaction.
    Que_0_14_3::Job.enqueue
    sleep_until { Que_0_14_3::Worker.workers.all?(&:sleeping?) && DB[:que_jobs_0_14_3].empty? }

    SEQUEL_ADAPTER_DB.transaction do
      Que_0_14_3::Job.enqueue
      Que_0_14_3::Worker.workers.each { |worker| worker.should be_sleeping }
    end
    sleep_until { Que_0_14_3::Worker.workers.all?(&:sleeping?) && DB[:que_jobs_0_14_3].empty? }

    # Do nothing when queueing with a specific :run_at.
    BlockJob.enqueue :run_at => Time.now
    Que_0_14_3::Worker.workers.each { |worker| worker.should be_sleeping }
  end

  it "should be able to tell when it's in a Sequel transaction" do
    Que_0_14_3.adapter.should_not be_in_transaction
    SEQUEL_ADAPTER_DB.transaction do
      Que_0_14_3.adapter.should be_in_transaction
    end
  end
end
