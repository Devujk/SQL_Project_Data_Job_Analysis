/*
What skills are most in demand for Data Analyst roles in Germany?
1. Filter Data Analyst postings by job_country = 'Germany'
2. Count how many postings list each skill
3. Show each skill as a percentage of German postings that list skills
*/

-- Total German DA postings
SELECT COUNT(*)
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
  AND job_country = 'Germany'; 
  
--(job_location = 'Germany' only matched 608 postings, because most German jobs list a city, e.g. "Berlin, Germany")

-- Top skills with percentage of postings
WITH de_jobs AS (
    SELECT DISTINCT jpf.job_id
    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
    WHERE jpf.job_title_short = 'Data Analyst'
      AND jpf.job_country = 'Germany'
)
SELECT
    sd.skills,
    COUNT(*) AS demand_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM de_jobs), 1) AS pct_of_postings
FROM de_jobs
INNER JOIN skills_job_dim sjd ON de_jobs.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY sd.skills
ORDER BY demand_count DESC
LIMIT 10;


/*
Insights:
1. 7,141 Data Analyst postings in Germany (the old job_location filter
   found only 608, about 9% of them).
2. SQL leads demand at 55.7% of postings with listed skills, followed by
   Python (43.8%), Tableau (25.9%), Excel (25.1%) and Power BI (24.6%).
3. SAP appears in 12.9% of German postings, far more common than in the
   global data, reflecting SAP's strong presence in German companies.
4. Percentages are based on the 5,288 postings that list at least one skill.
*/
