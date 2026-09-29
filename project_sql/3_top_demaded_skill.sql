/*
Question: What are the most in demand skills for data analyst jobs
1. Join job postings to inner join table similar to quers 
2. identify the top 5 in demand skills for a DA role
3. Focus on all job postings
4. Why? This give insigts to the most in demand skills for data analyst roles, helping job seekers understand which skills to develop that align with the top categories of salaries
*/  

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
WHERE
    job_title_short = 'Data Analyst' 
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5

-- for work from home DA roles

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
WHERE
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5

-- for germany

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
WHERE
    job_title_short = 'Data Analyst' AND
    job_country = 'Germany'
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5
