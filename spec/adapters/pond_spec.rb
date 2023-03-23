# frozen_string_literal: true

require 'spec_helper'
require 'pond'

Que_0_14_3.connection = QUE_SPEC_POND = Pond.new &NEW_PG_CONNECTION
QUE_ADAPTERS[:pond] = Que_0_14_3.adapter

describe "Que_0_14_3 using the Pond adapter" do
  before { Que_0_14_3.adapter = QUE_ADAPTERS[:pond] }

  it_behaves_like "a multi-threaded Que_0_14_3 adapter"

  it "should be able to tell when it's already in a transaction" do
    Que_0_14_3.adapter.should_not be_in_transaction
    QUE_SPEC_POND.checkout do |conn|
      conn.async_exec "BEGIN"
      Que_0_14_3.adapter.should be_in_transaction
      conn.async_exec "COMMIT"
    end
  end
end
