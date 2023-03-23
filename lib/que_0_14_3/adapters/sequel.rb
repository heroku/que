# frozen_string_literal: true

module Que_0_14_3
  module Adapters
    class Sequel < Base
      def initialize(db)
        @db = db
        super
      end

      def checkout(&block)
        @db.synchronize(&block)
      end

      def wake_worker_after_commit
        @db.after_commit { Que_0_14_3.wake! }
      end
    end
  end
end
