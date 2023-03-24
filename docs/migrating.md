## Migrating

Some new releases of Que_0_14_3 may require updates to the database schema. It's recommended that you integrate these updates alongside your other database migrations. For example, when Que_0_14_3 released version 0.6.0, the schema version was updated from 2 to 3. If you're running ActiveRecord, you could make a migration to perform this upgrade like so:

```ruby
class UpdateQue_0_14_3 < ActiveRecord::Migration
  def self.up
    Que_0_14_3.migrate! :version => 3
  end

  def self.down
    Que_0_14_3.migrate! :version => 2
  end
end
```

This will make sure that your database schema stays consistent with your codebase. If you're looking for something quicker and dirtier, you can always manually migrate in a console session:

```ruby
# Change schema to version 3.
Que_0_14_3.migrate! :version => 3

# Update to whatever the latest schema version is.
Que_0_14_3.migrate!

# Check your current schema version.
Que_0_14_3.db_version #=> 3
```

Note that you can remove Que_0_14_3 from your database completely by migrating to version 0.
