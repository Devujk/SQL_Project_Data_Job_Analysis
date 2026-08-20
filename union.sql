-- UNION
--Get jobs and companies from January

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    jan_jobs

UNION

--Get jobs and companies from February

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    feb_jobs

--Get jobs and companies from March

UNION

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    mar_jobs


--UNION ALL
--Get jobs and companies from January

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    jan_jobs

UNION ALL

--Get jobs and companies from February

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    feb_jobs

--Get jobs and companies from March

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    mar_jobs