ALTER TABLE que_jobs_0_14_3
  DROP CONSTRAINT que_jobs_0_14_3_pkey,
  ALTER COLUMN priority TYPE smallint,
  ADD COLUMN queue TEXT NOT NULL DEFAULT '',
  ADD CONSTRAINT que_jobs_0_14_3_pkey PRIMARY KEY (queue, priority, run_at, job_id);
