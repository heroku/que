# frozen_string_literal: true

require 'monitor'

module Que_0_14_3
  module Adapters
    class PG < Base
      attr_reader :lock

      def initialize(pg)
        @pg   = pg
        @lock = Monitor.new # Must be re-entrant.
        super
      end

      def checkout
        @lock.synchronize { yield @pg }
      end
    end
  end
end
