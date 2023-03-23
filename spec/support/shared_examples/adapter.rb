# frozen_string_literal: true

shared_examples "a Que_0_14_3 adapter" do
  it "should be able to execute arbitrary SQL and return indifferent hashes" do
    result = Que_0_14_3.execute("SELECT 1 AS one")
    result.should == [{'one'=>1}]
    result.first[:one].should == 1
  end

  it "should be able to cast boolean results properly" do
    r = Que_0_14_3.execute("SELECT true AS true_value, false AS false_value")
    r.should == [{'true_value' => true, 'false_value' => false}]
  end

  it "should be able to execute multiple SQL statements in one string" do
    Que_0_14_3.execute("SELECT 1 AS one; SELECT 1 AS one")
  end

  it "should be able to queue and work a job" do
    Que_0_14_3::Job.enqueue
    result = Que_0_14_3::Job.work
    result[:event].should == :job_worked
    result[:job][:job_class].should == 'Que_0_14_3::Job'
  end

  it "should yield the same Postgres connection for the duration of the block" do
    Que_0_14_3.adapter.checkout do |conn|
      conn.should be_a PG::Connection
      pid1 = Que_0_14_3.execute "SELECT pg_backend_pid()"
      pid2 = Que_0_14_3.execute "SELECT pg_backend_pid()"
      pid1.should == pid2
    end
  end

  it "should allow nested checkouts" do
    Que_0_14_3.adapter.checkout do |a|
      Que_0_14_3.adapter.checkout do |b|
        a.object_id.should == b.object_id
      end
    end
  end
end
