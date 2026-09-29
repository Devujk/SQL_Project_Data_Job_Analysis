# **Data Analyst Job Market Analysis - 2023 (SQL Project)**
## **Introduction**
This project explores the Data Analyst job market using real-world job posting data. Through a series of SQL queries, it investigates top-paying roles, the skills these roles demand, the most in-demand skills across the market, and which skills offer the strongest combination of demand and salary — the "optimal skills" for a Data Analyst to focus on. Several queries are also run for Germany specifically, to understand the market I'm applying in.

The queries and datasets used in this project can be found here: [project_sql folder](/project_sql/)

## **Background**

This project uses job posting data (2023) covering job titles, salaries, locations, companies, and required skills, structured across fact and dimension tables (job_postings_fact, company_dim, skills_job_dim, skills_dim).

The analysis was guided by six questions:

1. What are the top-paying Data Analyst jobs?
2. What skills are required for these top-paying Data Analyst jobs?
3. What skills are most in demand for Data Analyst roles?
4. Which skills are associated with the highest salaries?
5. What are the optimal skills to learn — high demand and high pay?
6. Which skills do Data Analyst postings in Germany ask for?

## **Tools Used**
- **PostgreSQL** — the database used to store and query the job postings dataset; all queries were written using PostgreSQL syntax (e.g. EXTRACT, CTEs, AT TIME ZONE).
- **VS Code (with a SQL extension)** — used to write, run, and organize all queries against the PostgreSQL database.
- **Git & GitHub** — for version control and to host and share this project.

## **Analysis**

Each query below was built to answer one specific question, moving from broad market patterns to a focused, actionable skill list.

### **Top-Paying Data Analyst Jobs**
Identifies the top 10 highest-paying remote Data Analyst roles with a specified salary, then narrows the same analysis to Germany specifically.

``` sql
SELECT
    job_id,
    job_title_short,
    job_location,
    job_schedule_type,
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
LIMIT 10;
```
#### **Insights**

- **Wide salary range:** Top-paying remote DA roles span from $184,000 to $650,000. Mantys ($650K) sits far above everything else and is likely an outlier or data error; Meta ($336K) follows, and the rest cluster between $184K and $256K.
- **All full-time:** every one of the top 10 remote postings is a full-time role.

![Top paying Data Analyst Jobs](assets/1_top_paying_jobs.png)
*Bar chart visualizing the salary for the top 10 highest-paying Data Analyst postings; generated with the help of Claude from the obtained SQL query results*

(a) Germany-specific findings
```sql
SELECT
    job_id,
    job_title_short,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    company_dim.name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_title_short = 'Data Analyst' AND
    job_country = 'Germany' AND
    salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```
#### **Insights**
- **Filter fix:** an earlier version filtered on `job_location = 'Germany'`, which only matched postings listed as just "Germany". Switching to `job_country` captures postings listed by city (Berlin, Munich, Hamburg etc.).
- **Salary data is too thin to use:** only 48 of 7,141 German DA postings include a salary.
- **The top values are implausible:** up to $200K (in USD) for analyst roles, with identical figures repeated across different companies. German salary results are therefore not used for conclusions.

### **Skills for Top Paying DA Jobs**
Using a CTE to isolate the top 10 highest-paying remote DA jobs, then joins to skills_job_dim/skills_dim to see which skills those specific roles require.

```sql
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
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id 
ORDER BY 
top_paying_jobs.salary_year_avg DESC
```
#### **Insights**
- SQL is required in every one of the 8 top-paying postings that listed skills — 100% coverage.
- Python (7 of 8) and Tableau (6 of 8) are close behind, both near-standard alongside SQL.
- 2 of the original top-10 postings list no skills at all in the dataset — a data gap, not a market signal.

![Skills Required by Top-Paying Data Analyst Jobs](assets/2_top_paying_job_skills.png)

*Bar chart showing the most frequently required skills among the top-paying remote Data Analyst jobs.*

### **Most In-Demand DA Skills**
Counts how often each skill appears across all Data Analyst postings overall.
```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id 
WHERE
    job_title_short = 'Data Analyst' 
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5
```
#### **Insights**
- SQL leads by a wide margin: 92,628 postings, ~40% more than #2 (Excel).
- Top 5 splits into two tiers: SQL/Excel lead (65K+ each), Python/Tableau/Power BI form a closer second tier (39K–57K each).
- Excel ranking above Python is a reminder that spreadsheet skills still matter, even in technical DA roles.
- In Germany, Python ranks second and Tableau edges past Excel.

| Rank | Overall | Remote | Germany |
|---|---|---|---|
| 1 | SQL (92,628) | SQL (7,291) | SQL (2,947) |
| 2 | Excel (67,031) | Excel (4,611) | Python (2,316) |
| 3 | Python (57,326) | Python (4,330) | Tableau (1,370) |
| 4 | Tableau (46,554) | Tableau (3,745) | Excel (1,327) |
| 5 | Power BI (39,468) | Power BI (2,609) | Power BI (1,303) |

*Table comparing the top 5 most in-demand Data Analyst skills across three markets based on the SQL query results (Germany filtered by job_country).*

### **Top Paying DA Skills**
Calculates the average salary associated with each skill for Data Analyst roles, run for both all postings and remote-only postings.
```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25
```
#### **Insights**
- SVN tops the list at $400K, but with very few postings behind it — likely a small-sample outlier, not a real market rate.
- Solidity ($179K) and Couchbase ($160K) lead the credible results — both niche, specialized skills (blockchain, NoSQL).
- DevOps tools cluster near the top: Terraform ($147K), GitLab ($134K), Kafka ($130K) — cross-over DevOps skills pay a premium even in analyst roles.

![Highest Paying DA Skills](assets/4_top_paying_skills.png)
*Bar chart visualizing the top 12 highest-paying skills; generated with the help of Claude from the SQL query results.*

### **Optimal DA Skills**

Combines demand and salary into a single view, filtering to skills appearing in more than 10 postings to avoid small-sample noise.
```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL 
    AND job_work_from_home = TRUE
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id) > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
LIMIT 25
```
#### **Insights**
- Go, Snowflake, and Azure balance demand and pay well: Go leads at $115K (27 postings), Snowflake ($113K, 37 postings) and Azure ($111K, 34 postings) aren't far behind.
- Python and Tableau offer the highest volume at solid (not top) pay: 236 and 230 postings, both averaging just over $100K — the safest bets even if not the highest earners.
- Data quality note: "sas" appears twice under different skill_ids with identical numbers — likely a duplicate entry, not two real skills.

![Optimal DA Skills](assets/5_optimal_skills.png)
*Scatter plot visualizing demand against average salary for skills with 10+ postings; generated with the help of Claude from the SQL query results.*

### **Germany Skill Demand**
Filters Data Analyst postings by `job_country = 'Germany'` and shows each skill as a share of German postings that list at least one skill.
```sql
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
```
#### **Insights**
- **7,141 Data Analyst postings in Germany**; the earlier `job_location` filter found only 608 of them (about 9%).
- **SQL leads at 55.7%** of postings with listed skills, followed by Python (43.8%), Tableau (25.9%), Excel (25.1%) and Power BI (24.6%).
- **SAP appears in 12.9% of German postings**, far more often than in the global data, reflecting SAP's strong presence in German companies.
- Grouping by skill name (not skill_id) also merges the duplicate skill entries noted above into a single count.
- Percentages are based on the 5,288 German postings that list at least one skill.

## **What I learned**
This project pushed me to go beyond basic queries and think in terms of real data workflows:

- Joins — combining job_postings_fact with dimension tables to pull in readable names instead of raw IDs, and knowing when a LEFT JOIN is needed to keep unmatched rows.
- Aggregate functions — using COUNT(), AVG(), and ROUND() with GROUP BY to summarize data by category, not just row by row.
- CTEs — breaking a complex question into a clear first step (WITH ... AS) before building the final query, making multi-step logic easier to read and debug.
- Query optimization — simplified the "optimal skills" query from two separate CTEs into one query using HAVING.
- Reading data critically — flagging real issues like a duplicate skill entry (sas under two IDs) and a small-sample outlier (svn at $400K), instead of reporting numbers at face value.
- Checking filters against the data — discovering that `job_location = 'Germany'` missed about 91% of German postings, and fixing it with `job_country`.
- Turning results into a story — writing clear findings and building visualizations mattered as much as the queries themselves.

## **Conclusion**
This project confirmed, with real data rather than assumption, that SQL, Python, Excel, Tableau, and Power BI form the practical foundation for an entry-level Data Analyst role, both globally and in Germany, where SAP also stands out. It also surfaced a clear next-step skill (a cloud platform, most likely Azure or AWS) worth building toward once the fundamentals are solid.

Beyond the specific findings, this project itself is evidence of applied SQL ability: multi-table joins, CTEs, subqueries, aggregate functions, and query optimization (simplifying a two-CTE query into a single query with HAVING) were all used to answer real, practically motivated questions.