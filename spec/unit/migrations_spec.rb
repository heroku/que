# frozen_string_literal: true

require 'spec_helper'

describe Que_0_14_3::Migrations do
  it "should be able to perform migrations up and down" do
    # Migration #1 creates the table with a priority default of 1, migration
    # #2 ups that to 100.

    default = proc do
      result = Que_0_14_3.execute <<-SQL
        select adsrc::integer
        from pg_attribute a
        join pg_class c on c.oid = a.attrelid
        join pg_attrdef on adrelid = attrelid AND adnum = attnum
        where relname = 'que_jobs'
        and attname = 'priority'
      SQL

      result.first[:adsrc]
    end

    default.call.should == 100
    Que_0_14_3::Migrations.migrate! :version => 1
    default.call.should == 1
    Que_0_14_3::Migrations.migrate! :version => 2
    default.call.should == 100

    # Clean up.
    Que_0_14_3.migrate!
  end

  it "should be able to get and set the current schema version" do
    Que_0_14_3::Migrations.db_version.should == Que_0_14_3::Migrations::CURRENT_VERSION
    Que_0_14_3::Migrations.set_db_version(59328)
    Que_0_14_3::Migrations.db_version.should == 59328
    Que_0_14_3::Migrations.set_db_version(Que_0_14_3::Migrations::CURRENT_VERSION)
    Que_0_14_3::Migrations.db_version.should == Que_0_14_3::Migrations::CURRENT_VERSION
  end

  it "should be able to cycle the jobs table all the way between nonexistent and current without error" do
    Que_0_14_3::Migrations.db_version.should == Que_0_14_3::Migrations::CURRENT_VERSION
    Que_0_14_3::Migrations.migrate! :version => 0
    Que_0_14_3::Migrations.db_version.should == 0
    Que_0_14_3.db_version.should == 0
    Que_0_14_3::Migrations.migrate!
    Que_0_14_3::Migrations.db_version.should == Que_0_14_3::Migrations::CURRENT_VERSION

    # The helper on the Que_0_14_3 module does the same thing.
    Que_0_14_3.migrate! :version => 0
    Que_0_14_3::Migrations.db_version.should == 0
    Que_0_14_3.migrate!
    Que_0_14_3::Migrations.db_version.should == Que_0_14_3::Migrations::CURRENT_VERSION
  end

  it "should be able to honor the initial behavior of Que_0_14_3.drop!" do
    DB.table_exists?(:que_jobs).should be true
    Que_0_14_3.drop!
    DB.table_exists?(:que_jobs).should be false

    # Clean up.
    Que_0_14_3::Migrations.migrate!
    DB.table_exists?(:que_jobs).should be true
  end

  it "should be able to recognize a que_jobs table created before the versioning system" do
    DB.drop_table :que_jobs
    DB.create_table(:que_jobs){serial :id} # Dummy Table.
    Que_0_14_3::Migrations.db_version.should == 1
    DB.drop_table(:que_jobs)
    Que_0_14_3::Migrations.migrate!
  end

  it "should be able to honor the initial behavior of Que_0_14_3.create!" do
    DB.drop_table :que_jobs
    Que_0_14_3.create!
    DB.table_exists?(:que_jobs).should be true
    Que_0_14_3::Migrations.db_version.should == 1

    # Clean up.
    Que_0_14_3::Migrations.migrate!
    DB.table_exists?(:que_jobs).should be true
  end
end
