-- Subqueries
SELECT *
FROM(
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS jan_jobs;

-- Common Tbale Expressions (CTE)
WITH jan_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)
SELECT *
FROM jan_jobs;

--company that offer jobs that don't have any requirements for degree (Subquery)
SELECT 
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT DISTINCT
        company_id
    FROM 
        job_postings_fact
    WHERE 
        job_no_degree_mention = true
    ORDER BY 
        company_id
);

/* 
Find the companies that have the most job openeings
Get the total number of job postings per company id (job_postings_fact)
Return the total number of jobs with the company name (company_dim)
*/
WITH company_job_count AS (
    SELECT
        company_id,
        COUNT (*) 
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT *
FROM company_job_count

-- applying a left join to combine company_dim and job_posting_fact to get the details of thhe companies that have postings even if there isn't any.


WITH company_job_count AS (
    SELECT
        company_id,
        COUNT (*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC