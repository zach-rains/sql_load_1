# Introduction
Explore the data job market, focusing on data analyst roles by exploring top-paying jobs, most in-demand skills and where the two meet.

SQL Queries Here: [sql_project folder](/project_sql/)
# Background
This project was created from a desire to analyze the data analyst job market, by taking a dive into where the highest-paid jobs meet the most in-demand skills.

The data originates from an online [SQL Course](https://lukebarousse.com/sql)

### The five questions I wanted to answer with my analysis:
1. What are the top-paying data analyst jobs?
2. What skills are required for the top-paying data analyst jobs?
3. What are the most in-demand skills for data analysts?
4. What are the top skills based on salary?
5. What are the highest-paying, most in-demand skills?

# Tools I Used
-**SQL**: used to query the database and identify key insights
-**Postrgresql**: database management system for handling the job posting data
-**Visual Studio Code**: used to execute the SQL queries
-**Git & GitHub**: used for version control, sharing SQL scripts and analysis
# The Analysis
### 1. Top Paying Data Analyst Jobs
To identify the highest-paying jobs, I filtered the data to data analyst positions, by average yearly salary and remote location.
```sql
SELECT
    name AS companay_name,
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND 
    salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```
![Top Paying Roles](project_sql/top_paying_jobs.png)

### 2. Necessary Skills For The Top Paying Jobs
To find the skills that the top-paying jobs require I took the query from the previous question, and joined it with two other tables to identify the skills necessary. The joins added the skill id and skill name to my query, which allowed me to identify the necessary skills of the top paying jobs.
```sql
WITH top_paying_jobs AS (
    SELECT
        name AS companay_name,
        job_id,
        job_title,
        salary_year_avg,
        job_posted_date
    FROM
        job_postings_fact
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
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC
```

### 3. Top Demanded Skills
To establish which skills are most in-demand, I aggregated all of the skills listed for all of the data analyst, remote work jobs. 
```sql
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  -- Filters job titles for 'Data Analyst' roles
  job_postings_fact.job_title_short = 'Data Analyst'
	-- AND job_work_from_home = True -- optional to filter for remote jobs
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;
```
| skills   |   demand_count |
|:---------|---------------:|
| sql      |          92628 |
| excel    |          67031 |
| python   |          57326 |
| tableau  |          46554 |
| power bi |          39468 |

*Table of the demand for the top 5 skills in data analyst job openings.*

### 4. Top Paying Skills
To establish which skills are the highest paid skills I found the average pay for each of the most common data analyst skills. This query establishes the most financially rewarding skills for data analysts.
```sql
SELECT
  skills_dim.skills,
  ROUND(AVG(salary_year_avg), 0) AS average_salary
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  -- Filters job titles for 'Data Analyst' roles
  job_postings_fact.job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
  AND job_work_from_home = True -- optional to filter for remote jobs
GROUP BY
  skills
ORDER BY
    average_salary DESC
LIMIT 25;
```
| Skills           | Average Salary |
|------------------|----------------|
| pyspark          | $208,172       |
| bitbucket        | $189,155       |
| couchbase        | $160,515       |
| watson           | $160,515       |
| datarobot        | $155,486       |
| gitlab           | $154,500       |
| swift            | $153,750       |
| jupyter          | $152,777       |
| pandas           | $151,821       |
| elasticsearch    | $145,000       |
| golang           | $145,000       |
| numpy            | $143,513       |
| databricks       | $141,907       |
| linux            | $136,508       |
| kubernetes       | $132,500       |
| atlassian        | $131,162       |
| twilio           | $127,000       |
| airflow          | $126,103       |
| scikit-learn     | $125,781       |
| jenkins          | $125,436       |
| notion           | $125,000       |
| scala            | $124,903       |
| postgresql       | $123,879       |
| gcp              | $122,500       |
| micro

*Table of the top-paying skills.*

### 5. Most Optimal Skills
This query was made to establish what the most optimal (high-demand and high-paying) skills for data analysts are. I concentrated on remote jobs that had specified salaries.
```sql
WITH skills_demand AS (
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM
        job_postings_fact
    INNER JOIN
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
    -- Filters job titles for 'Data Analyst' roles
        job_postings_fact.job_title_short = 'Data Analyst'
        AND job_work_from_home = TRUE
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_dim.skill_id
), average_salary AS(
    SELECT
        skills_job_dim.skill_id,
        AVG(salary_year_avg) AS avg_salary
    FROM
        job_postings_fact
    INNER JOIN
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
    -- Filters job titles for 'Data Analyst' roles
        job_postings_fact.job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY
        skills_job_dim.skill_id
)

SELECT
  skills_demand.skills,
  skills_demand.demand_count,
  ROUND(average_salary.avg_salary, 2) AS avg_salary --ROUND to 2 decimals 
FROM
  skills_demand
	INNER JOIN
	  average_salary ON skills_demand.skill_id = average_salary.skill_id
-- WHERE demand_count > 10
ORDER BY
  demand_count DESC, 
	avg_salary DESC
LIMIT 10 --Limit 25
; 
```
| Skills      | Demand Count | Average Salary |
|-------------|--------------|----------------|
| sql         | 398          | $97,237.16     |
| excel       | 256          | $87,288.21     |
| python      | 236          | $101,397.22    |
| tableau     | 230          | $99,287.65     |
| r           | 148          | $100,498.77    |
| power bi    | 110          | $97,431.30     |
| sas         | 63           | $98,902.37     |
| powerpoint  | 58           | $88,701.09     |
| looker      | 49           | $103,795.30    |

*Table of the top-paying, most in demand skills.*

# What I Learned
Through this analysis I learned a few things that have improved my data analysis skillset:

- **Creating Complex Queries:** Developed the ability to use advanced SQL, such as WITH clauses for temp tables, joins and multiple joins, along with aggregate functions.
- **Data Aggregation:** Got compfortable using GROUP BY along with data summarization functions like COUNT() and AVG().
- **Analytical Skills:** Increased my capacity to take multiple datasets and glean insights from their analysis.

# Conclusions

### Insights
The following insights were gleaned from the analysis:

1. **Top-Paying Data Analyst Jobs**: Top-paying remote data analyst roles offer a wide salary range, with some reaching up to $650,000!
2. **Skills for Top-Paying Jobs**: Advanced SQL proficiency is essential for securing high-paying data analyst positions, signaling its importance in earning top salaries.
3. **Most In-Demand Skills**: SQL remains the most sought-after skill in the data analyst job market, making it crucial for job seekers.
4. **Skills with Higher Salaries**: Specialized skills like SVN and Solidity are tied to the highest average salaries, highlighting the value of niche expertise.
5. **Optimal Skills for Job Market Value**: SQL stands out as both highly demanded and well-compensated, making it one of the most valuable skills for data analysts aiming to enhance their market appeal.
