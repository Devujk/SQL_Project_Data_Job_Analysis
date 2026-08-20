SELECT 
    job_title_short,
    job_location
FROM 
    job_postings_fact;

/*
 Label new coulummn as follows:
 1. 'Anywhere' jobs as 'Remote'
 2. 'New York, NY' jobs as 'Local'
 3. Otherwise 'Onsite'

 */

 SELECT 
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM 
    job_postings_fact;

-- Categories into onsite, remore and local for DA jobs (using GROUP BY)

SELECT 
    COUNT (job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;