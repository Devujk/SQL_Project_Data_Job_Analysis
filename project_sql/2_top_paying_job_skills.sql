/*

Question: What skills are required for top paying analyst jobs?
1. Use the top 10 paying DA jobs from first query
2. Add te specific skills required for these roles
3. Why? It provides a detailes look at which the highes paying jobs demand certail skills, 
helping job seekets understand which skills to developp that align with the top categories of salaries
*/


WITH top_paying_jobs AS (
    SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    job_posted_date,
    company_dim.name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE 
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)   

SELECT 
    top_paying_jobs.*,
    skills_dim.skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
ORDER BY 
top_paying_jobs.salary_year_avg DESC


/* Insights
1. SQL is the laeading with a count of 8
2. python flowws closely with a count of 7
3. Tableu with a count of 6
4. Other skills like R, Excel, Power BI, and Data Visualization are also in demand but with lower 
*/

