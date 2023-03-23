# frozen_string_literal: true

class AddQue_0_14_3 < ActiveRecord::Migration[4.2]
  def self.up
    # The current version as of this migration's creation.
    Que_0_14_3.migrate! :version => 3
  end

  def self.down
    # Completely removes Que_0_14_3's job queue.
    Que_0_14_3.migrate! :version => 0
  end
end
