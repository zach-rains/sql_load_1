/*
Question: What are the top skills based on salary?
-Look at average salary based on skill
*/

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