-- Creatr tables from other tables
--For Jan 2023 Jobs

-- January
CREATE TABLE jan_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE feb_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE mar_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

--Testing
SELECT job_posted_date
FROM mar_jobs;