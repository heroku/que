## Customizing Que_0_14_3

One of Que_0_14_3's goals to be easily extensible and hackable (and if anyone has any suggestions on ways to accomplish that, please [open an issue](https://github.com/chanks/que/issues)). This document is meant to demonstrate some of the ways Que_0_14_3 can be used to accomplish different tasks that it's not already designed for.

Some of these features may be moved into core Que_0_14_3 at some point, depending on how commonly useful they are.

### Recurring Jobs

Que_0_14_3's support for scheduling jobs makes it easy to implement reliable recurring jobs. For example, suppose you want to run a job every hour that processes the users created in that time:

```ruby
class CronJob < Que_0_14_3::Job
  # Default repetition interval in seconds. Can be overridden in
  # subclasses. Can use 1.minute if using Rails.
  INTERVAL = 60

  attr_reader :start_at, :end_at, :run_again_at, :time_range

  def _run
    args = attrs[:args].first
    @start_at, @end_at = Time.at(args.delete('start_at')), Time.at(args.delete('end_at'))
    @run_again_at = @end_at + self.class::INTERVAL
    @time_range = @start_at...@end_at

    super

    args['start_at'] = @end_at.to_f
    args['end_at']   = @run_again_at.to_f
    self.class.enqueue(args, run_at: @run_again_at)
  end
end

class MyCronJob < CronJob
  INTERVAL = 3600

  def run(args)
    User.where(created_at: time_range).each { ... }
  end
end

# To enqueue:
tf = Time.now
t0 = Time.now - 3600
MyCronJob.enqueue :start_at => t0.to_f, :end_at => tf.to_f
```

Note that instead of using Time.now in our database query, and requeueing the job at 1.hour.from_now, we use job arguments to track start and end times. This lets us correct for delays in running the job. Suppose that there's a backlog of priority jobs, or that the worker briefly goes down, and this job, which was supposed to run at 11:00 a.m. isn't run until 11:05 a.m. A lazier implementation would look for users created after 1.hour.ago, and miss those that signed up between 10:00 a.m. and 10:05 a.m.

This also compensates for clock drift. `Time.now` on one of your application servers may not match `Time.now` on another application server may not match `now()` on your database server. The best way to stay reliable is have a single authoritative source on what the current time is, and your best source for authoritative information is always your database (this is why Que_0_14_3 uses Postgres' `now()` function when locking jobs, by the way).

Note also the use of the triple-dot range, which results in a query like `SELECT "users".* FROM "users" WHERE ("users"."created_at" >= '2014-01-08 10:00:00.000000' AND "users"."created_at" < '2014-01-08 11:00:00.000000')` instead of a BETWEEN condition. This ensures that a user created at 11:00 am exactly isn't processed twice, by the jobs starting at both 10 am and 11 am.

Finally, by passing both the start and end times for the period to be processed, and only using the interval to calculate the period for the following job, we make it easy to change the interval at which the job runs, without the risk of missing or double-processing any users.

### DelayedJob-style Jobs

DelayedJob offers a simple API for delaying methods to objects:

```ruby
@user.delay.activate!(@device)
```

The API is pleasant, but implementing it requires storing marshalled Ruby objects in the database, which is both inefficient and prone to bugs - for example, if you deploy an update that changes the name of an instance variable (a contained, internal change that might seem completely innocuous), the marshalled objects in the database will retain the old instance variable name and will behave unexpectedly when unmarshalled into the new Ruby code.

This is the danger of mixing the ephemeral state of a Ruby object in memory with the more permanent state of a database row. The advantage of Que_0_14_3's API is that, since your arguments are forced through a JSON serialization/deserialization process, it becomes your responsibility when designing a job class to establish an API for yourself (what the arguments to the job are and what they mean) that you will have to stick to in the future.

That said, if you want to queue jobs in the DelayedJob style, that can be done relatively easily:

```ruby
class Delayed < Que_0_14_3::Job
  def run(receiver, method, args)
    Marshal.load(receiver).send method, *Marshal.load(args)
  end
end

class DelayedAction
  def initialize(receiver)
    @receiver = receiver
  end

  def method_missing(method, *args)
    Delayed.enqueue Marshal.dump(@receiver), method, Marshal.dump(args)
  end
end

class Object
  def delay
    DelayedAction.new(self)
  end
end
```

You can replace Marshal with YAML if you like.

### QueueClassic-style Jobs

You may find it a hassle to keep an individual class file for each type of job. QueueClassic has a simpler design, wherein you simply give it a class method to call, like:

```ruby
QC.enqueue("Kernel.puts", "hello world")
```

You can mimic this style with Que_0_14_3 by using a simple job class:

```ruby
class Command < Que_0_14_3::Job
  def run(method, *args)
    receiver, message = method.split('.')
    Object.const_get(receiver).send(message, *args)
  end
end

# Then:

Command.enqueue "Kernel.puts", "hello world"
```

### Retaining Finished Jobs

Que_0_14_3 deletes jobs from the queue as they are worked, in order to keep the `que_jobs` table and index small and efficient. If you have a need to hold onto finished jobs, the recommended way to do this is to add a second table to hold them, and then insert them there as they are deleted from the queue. You can use Ruby's inheritance mechanics to do this cleanly:

```ruby
Que_0_14_3.execute "CREATE TABLE finished_jobs AS SELECT * FROM que_jobs LIMIT 0"
# Or, better, use a proper CREATE TABLE with not-null constraints, and add whatever indexes you like.

class MyJobClass < Que_0_14_3::Job
  def destroy
    Que_0_14_3.execute "INSERT INTO finished_jobs SELECT * FROM que_jobs WHERE queue = $1::text AND priority = $2::integer AND run_at = $3::timestamptz AND job_id = $4::bigint", @attrs.values_at(:queue, :priority, :run_at, :job_id)
    super
  end
end
```

Then just have your job classes inherit from MyJobClass instead of Que_0_14_3::Job. If you need to query the jobs table and you want to include both finished and unfinished jobs, you might use:

```ruby
Que_0_14_3.execute "CREATE VIEW all_jobs AS SELECT * FROM que_jobs UNION ALL SELECT * FROM finished_jobs"
Que_0_14_3.execute "SELECT * FROM all_jobs"
```

Alternately, if you want a more foolproof solution and you're not scared of PostgreSQL, you can use a trigger:

```sql
CREATE FUNCTION please_save_my_job()
RETURNS trigger
LANGUAGE plpgsql
AS $$
  BEGIN
    INSERT INTO finished_jobs SELECT (OLD).*;
    RETURN OLD;
  END;
$$;

CREATE TRIGGER keep_all_my_old_jobs BEFORE DELETE ON que_jobs FOR EACH ROW EXECUTE PROCEDURE please_save_my_job();
```

### Not Retrying Certain Failed Jobs

By default, when jobs fail, Que_0_14_3 reschedules them to be retried later. If instead you'd like certain jobs to not be retried, and instead move them elsewhere to be examined later, you can accomplish that easily. First, we need a place for the failed jobs to be stored:

```sql
CREATE TABLE failed_jobs AS SELECT * FROM que_jobs LIMIT 0
```

Then, create a module that you can use in the jobs you don't want to retry:

```ruby
module SkipRetries
  def run(*args)
    super
  rescue
    sql = <<-SQL
      WITH failed AS (
        DELETE
        FROM   que_jobs
        WHERE  queue    = $1::text
        AND    priority = $2::smallint
        AND    run_at   = $3::timestamptz
        AND    job_id   = $4::bigint
        RETURNING *
      )
      INSERT INTO failed_jobs
        SELECT * FROM failed;
    SQL

    Que_0_14_3.execute sql, @attrs.values_at(:queue, :priority, :run_at, :job_id)

    raise # Reraises caught error.
  end
end

class RunOnceJob < Que_0_14_3::Job
  prepend SkipRetries

  def run(*args)
    # Do something - if this job runs an error it'll be moved to the
    # failed_jobs table and not retried.
  end
end
```
