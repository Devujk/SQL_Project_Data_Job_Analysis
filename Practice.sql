--Query to find the average salary both yearly (salary_year_avg) and hourly (salary_hour avg) for job postings that were posted after June 1, 2023 
--Group the results by job schedule type

SELECT 
    job_schedule_type,
    AVG(salary_year_avg) AS salary_year_avg,
    AVG (salary_hour_avg) AS salary_hour_avg
FROM job_postings_fact
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type;

-- Query to count the number of job postings for each month in 2023, adjusting the job_posted_date to be in 'America/New York' time zone before extracting the month
--Assume the job_posted_date is stored in UTY
--GRoup by and order by the month

SELECT 
    EXTRACT(
        MONTH FROM job_posted_date 
        AT TIME ZONE 'UTC' 
        AT TIME ZONE 'America/New_York'
    ) AS job_posted_month,

    COUNT(job_id) AS job_posting_count

FROM job_postings_fact

WHERE 
    job_posted_date >= '2023-01-01'
    AND job_posted_date < '2024-01-01'

GROUP BY 
    job_posted_month

ORDER BY 
    job_posted_month;


-- Query to find companies (including company name) that have posted jobs offering health insurance
-- Where postings made in second quarter of 2023
-- Use date extraction to filter by quarter

SELECT DISTINCT
    job_postings_fact.company_id,
    company_dim.name AS company_name
FROM job_postings_fact 
JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT (YEAR FROM job_posted_date)=2023
    AND EXTRACT (QUARTER FROM job_posted_date)=2;

-- Identify the top 5 skills that are most frequently mentioned in job postings
-- Use subquery to find skill IDs with the highest counts in the skills_job_dim table
-- Join this resul with the skills_dim table to get the skill names

SELECT
    skills_dim.skill_id,
    skills_dim.skills AS skill_name
FROM
    (
        SELECT
        skill_id,
        COUNT(*) AS skill_count
        FROM skills_job_dim
        GROUP BY skill_id
        ORDER BY skill_count DESC
        LIMIT 5
    ) AS top_skills
JOIN skills_dim ON top_skills.skill_id = skills_dim.skill_id
ORDER BY top_skills.skill_count DESC;

--Identify the top 5 skills that are used by the highest number of distinct companies
-- Use job_postings_fact to connect skills to the companies that posted them
-- Join skills_job_dim, job_postings_fact, and skills_dim as needed
-- Count distinct companies per skill, not just mentions

SELECT DISTINCT
    skills_dim.skills AS skill_name,
    company_dim.name AS company_name
FROM skills_job_dim
JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE skills_job_dim.skill_id IN (
    SELECT skill_id
    FROM skills_job_dim
    JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
    GROUP BY skill_id
    ORDER BY COUNT(DISTINCT company_id) DESC
    LIMIT 5
)
ORDER BY skill_name, company_name;


-- Categorize each company as 'Small', 'Medium', or 'Large' based on the number of job postings
-- Use a subquery to calculate the total number of job postings for each company
-- 'Small' = less than 10 job postings
-- 'Medium' = between 10 and 50 job postings
-- 'Large' = more than 50 job postings
-- Return the company ID, total job postings, and company size category

SELECT
    company_id,
    postings_count,
    CASE
        WHEN postings_count < 10 THEN 'Small'
        WHEN postings_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM(
    SELECT
    company_id,
    COUNT(*) AS postings_count
    FROM job_postings_fact
    GROUP BY company_id
    ) AS company_counts;


-- Get corresponsing skill and skill type for each job postings in q1
-- include those without any skills too
-- Look at the skills and the type for each job in  q1 that has a salary > 70,000

SELECT
    job_postings_fact.job_id,
    skills_job_dim.skill_id,
    skills_dim.skills
FROM job_postings_fact
JOIN skills_job_dim ON skills_job_dim.job_id = job_postings_fact.job_id
JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE EXTRACT(QUARTER FROM job_posted_date) = 1
  AND job_postings_fact.salary_year_avg > 70000

UNION ALL

SELECT
    job_postings_fact.job_id,
    NULL AS skill_id,
    NULL AS skills
FROM job_postings_fact
WHERE EXTRACT(QUARTER FROM job_posted_date) = 1
  AND job_postings_fact.salary_year_avg > 70000
  AND job_id NOT IN (SELECT job_id FROM skills_job_dim)

/*
Find job postings from the first quater that have a salaray greater that $70k
- Combine job posting table from the first quater of 2023 (Jan-Mar)
- Gets job postings with an average yearly salary > $70,000
*/

SELECT 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date :: date,
    quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM jan_jobs
    UNION ALL
    SELECT *
    FROM feb_jobs
    UNION ALL
    SELECT *
    FROM mar_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC;