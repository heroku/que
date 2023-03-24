## Error Handling

If an error is raised and left uncaught by your job, Que_0_14_3 will save the error message and backtrace to the database and schedule the job to be retried later.

If a given job fails repeatedly, Que_0_14_3 will retry it at exponentially-increasing intervals equal to (failure_count^4 + 3) seconds. This means that a job will be retried 4 seconds after its first failure, 19 seconds after its second, 84 seconds after its third, 259 seconds after its fourth, and so on until it succeeds. This pattern is very similar to DelayedJob's. Alternately, you can define your own retry logic by setting an interval to delay each time, or a callable that accepts the number of failures and returns an interval:

```ruby
class MyJob < Que_0_14_3::Job
  # Just retry a failed job every 5 seconds:
  @retry_interval = 5

  # Always retry this job immediately (not recommended, or transient
  # errors will spam your error reporting):
  @retry_interval = 0

  # Increase the delay by 30 seconds every time this job fails:
  @retry_interval = proc { |count| count * 30 }
end
```

Unlike DelayedJob, however, there is currently no maximum number of failures after which jobs will be deleted. Que_0_14_3's assumption is that if a job is erroring perpetually (and not just transiently), you will want to take action to get the job working properly rather than simply losing it silently.

If you're using an error notification system (highly recommended, of course), you can hook Que_0_14_3 into it by setting a callable as the error notifier:

```ruby
Que_0_14_3.error_notifier = proc do |error, job|
  # Do whatever you want with the error object or job row here.

  # Note that the job passed is not the actual job object, but the hash
  # representing the job row in the database, which looks like:

  # {
  #   "queue" => "my_queue",
  #   "priority" => 100,
  #   "run_at" => 2015-03-06 11:07:08 -0500,
  #   "job_id" => 65,
  #   "job_class" => "MyJob",
  #   "args" => ['argument', 78],
  #   "error_count" => 0
  # }

  # This is done because the job may not have been able to be deserialized
  # properly, if the name of the job class was changed or the job is being
  # retrieved and worked by the wrong app. The job argument may also be
  # nil, if there was a connection failure or something similar.
end
```
