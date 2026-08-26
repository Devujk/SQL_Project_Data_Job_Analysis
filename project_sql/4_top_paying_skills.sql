/*
Question: What are the top skills based on salary?
1. Look at the average salary associated with each skill for DA positions
2. Focuses on role specifies salaries, regardless of location
3. Why? It gives insights in how different skills impact the salary levels of DA and helps identify the most financially rewarding skills to acquire or to improve
*/

SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25

--For remote jobs

SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id --we need skills that  are available for top paying jobs so inner join so that null won't be retrieved
WHERE
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE AND
    salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25

/*
Insights:
1. Data Engineering & Big Data: PySpark, Databricks, Airflow, Scala — among the strongest-paying skills, with PySpark leading at ~$208K.
2. Data Science & Machine Learning: Pandas, NumPy, Scikit-learn, Jupyter, DataRobot, Watson — generally showing high salaries of roughly $126K–$160K.
3. Cloud, DevOps & Infrastructure: GCP, Kubernetes, Linux, Jenkins, GitLab, Bitbucket, Elasticsearch — also highly valued, with several skills exceeding $130K average salary.