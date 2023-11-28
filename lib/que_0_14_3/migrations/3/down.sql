ALTER TABLE que_jobs_0_14_3
  DROP CONSTRAINT que_jobs_0_14_3_pkey,
  DROP COLUMN queue,
  ALTER COLUMN priority TYPE integer,
  ADD CONSTRAINT que_jobs_0_14_3_pkey PRIMARY KEY (priority, run_at, job_id);
