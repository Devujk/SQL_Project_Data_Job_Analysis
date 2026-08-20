--date
SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

--Handling date
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date :: DATE AS date                         --Extracting date from the dae and timestamp combination
FROM job_postings_fact;

--At Time Zones
-- used to convert timestams between different time zones
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST',
    EXTRACT ( MONTH FROM job_posted_date) AS date_month,  -- Extracting month, date or year
    EXTRACT ( YEAR FROM job_posted_date) AS date_year
FROM job_postings_fact
LIMIT 5;

-- Finding the trend of job posting over each month

SELECT 
    COUNT(job_id) AS job_postings_count,
    EXTRACT ( MONTH FROM job_posted_date) AS numeric_month,  -- Extracting month, date or year
    TO_CHAR (job_posted_date, 'Mon') AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY 
    numeric_month,
    month
ORDER BY
    job_postings_count DESC;

-- Output contains the column job_postings_count, numeric_month, and month.

-- To get the result as job_postings_count and month.
SELECT 
    COUNT(job_id) AS job_postings_count,
    TO_CHAR (job_posted_date, 'Mon') AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY 
    EXTRACT ( MONTH FROM job_posted_date),   -- Extracting month, date or year
    TO_CHAR (job_posted_date, 'Mon') 
ORDER BY
    job_postings_count DESC;
