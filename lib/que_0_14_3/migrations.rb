# frozen_string_literal: true

module Que_0_14_3
  module Migrations
    # In order to ship a schema change, add the relevant up and down sql files
    # to the migrations directory, and bump the version both here and in the
    # add_que generator template.
    CURRENT_VERSION = 3

    class << self
      def migrate!(options = {:version => CURRENT_VERSION})
        Que_0_14_3.transaction do
          version = options[:version]

          if (current = db_version) == version
            return
          elsif current < version
            direction = 'up'
            steps = ((current + 1)..version).to_a
          elsif current > version
            direction = 'down'
            steps = ((version + 1)..current).to_a.reverse
          end

          steps.each do |step|
            sql = File.read("#{File.dirname(__FILE__)}/migrations/#{step}/#{direction}.sql")
            Que_0_14_3.execute(sql)
          end

          set_db_version(version)
        end
      end

      def db_version
        result = Que_0_14_3.execute <<-SQL
          SELECT relname, description
          FROM pg_class
          LEFT JOIN pg_description ON pg_description.objoid = pg_class.oid
          WHERE relname = 'que_jobs_0_14_3'
        SQL

        if result.none?
          # No table in the database at all.
          0
        elsif (d = result.first[:description]).nil?
          # There's a table, it was just created before the migration system existed.
          1
        else
          d.to_i
        end
      end

      def set_db_version(version)
        i = version.to_i
        Que_0_14_3.execute "COMMENT ON TABLE que_jobs_0_14_3 IS '#{i}'" unless i.zero?
      end
    end
  end
end
