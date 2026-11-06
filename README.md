# GROUPB-October-2026
Sule Juliet
Section B 
QUESTION 4-7

-- Question 4
-- How many records were downloaded or exported from each system, and which employees moved the most records?

-- records downloaded or exported from each system
SELECT s.system_name,SUM(a.records_accessed) AS total_records_moved
FROM access_logs a
JOIN systems s ON a.system_id = s.system_id
WHERE a.action_type IN ('Download', 'Export')
  AND a.access_result = 'Granted'
GROUP BY s.system_name
ORDER BY total_records_moved DESC;

-- Employees who moved the most records

SELECT
e.employee_name,
SUM(a.records_accessed) AS total_records_moved
FROM access_logs a
JOIN employees e
ON a.employee_id = e.employee_id
WHERE a.action_type IN ('Download', 'Export')
AND a.access_result = 'Granted'
GROUP BY e.employee_name
ORDER BY total_records_moved DESC;


-- Question 5
-- What proportion of access happens outside business hours, and which employees account for most of it?

SELECT COUNT(*) AS total_access_events,SUM(CASE
WHEN DAYOFWEEK(access_timestamp) = 1
OR DAYOFWEEK(access_timestamp) = 7
OR TIME(access_timestamp) < '08:00:00'
OR TIME(access_timestamp) >= '18:00:00'
THEN 1
ELSE 0
END
) AS out_of_hours_events,
ROUND(SUM(CASE WHEN DAYOFWEEK(access_timestamp) = 1
OR DAYOFWEEK(access_timestamp)OR TIME(access_timestamp) < '08:00:00'
OR TIME(access_timestamp) >= '18:00:00'
THEN 1
ELSE 0
END) * 100.0 / COUNT(*),2) AS out_of_hours_percentage
FROM access_logs;


-- identify employees with the most out of hours access
SELECT 
    e.employee_name, COUNT(*) AS out_of_hours_events
FROM
    access_logs a
        JOIN
    employees e ON a.employee_id = e.employee_id
WHERE
    DAYOFWEEK(a.access_timestamp) IN (1 , 7)
        OR TIME(a.access_timestamp) < '08:00:00'
        OR TIME(a.access_timestamp) >= '18:00:00'
GROUP BY e.employee_name
ORDER BY out_of_hours_events DESC;


-- Question 6
-- How does access location (Office, VPN, Remote) differ across data classifications?

SELECT
s.data_classification,
a.access_location,
COUNT(*) AS total_accesses
FROM access_logs a
JOIN systems s
ON a.system_id = s.system_id
GROUP BY
s.data_classification,
a.access_location
ORDER BY
s.data_classification;
    
    
-- Question 7
-- Which employees accessed Confidential or Restricted systems owned by a department other than their own?

SELECT e.employee_name,e.department,s.system_name,s.data_classification,s.owner_department
FROM employees e, systems s, access_logs a
WHERE e.employee_id = a.employee_id
AND s.system_id = a.system_id
AND s.data_classification IN ('Confidential', 'Restricted')
AND e.department != s.owner_department
AND a.access_result = 'Granted';


MERCY DAMINABO
 D. phishing and email security
-- D1. how many emails fall into each category, and what share were phishing or malware? 

create database INVESTIGATION;
USE  INVESTIGATION;
show tables;
select * from employees;

SELECT email_category, COUNT(*) AS email_count
FROM email_security_events
GROUP BY email_category
ORDER BY email_count DESC;

-- D2. What is the click rate on malicious emails, overall and by department? 
-- i. OVERALL
SELECT
  COUNT(*) AS malicious_emails,
  SUM(user_action IN ('Clicked Link', 'Opened Attachment')) AS clicked_or_opened,
  ROUND(
    100 * SUM(user_action IN ('Clicked Link', 'Opened Attachment')) / COUNT(*),
    1
  ) AS click_rate_pct
FROM email_security_events
WHERE email_category IN ('Phishing', 'Malware');

-- ii. by DEPARTMENT
SELECT
  UPPER(TRIM(e.department)) AS department,
  COUNT(*) AS malicious_emails,
  SUM(s.user_action IN ('Clicked Link', 'Opened Attachment')) AS clicked_or_opened,
  ROUND(
    100 * SUM(s.user_action IN ('Clicked Link', 'Opened Attachment')) / COUNT(*),
    1
  ) AS click_rate_pct
FROM email_security_events AS s
JOIN employees AS e USING (employee_id)
WHERE s.email_category IN ('Phishing', 'Malware')
GROUP BY UPPER(TRIM(e.department))
ORDER BY click_rate_pct DESC;

-- D3. What is the report rate on malicious emails by department? Which departments respond best?

SELECT
  UPPER(TRIM(e.department)) AS department,
  COUNT(*) AS malicious_emails,
  SUM(s.user_action = 'Reported') AS reported,
  ROUND(100 * SUM(s.user_action = 'Reported') / COUNT(*), 1) AS report_rate_pct
FROM email_security_events AS s
JOIN employees AS e USING (employee_id)
WHERE s.email_category IN ('Phishing', 'Malware')
GROUP BY UPPER(TRIM(e.department))
ORDER BY report_rate_pct DESC;

-- D4. Which employees interacted with malicious emails more than once?

SELECT
  e.employee_name,
  TRIM(e.department) AS department,
  COUNT(*) AS interactions
FROM email_security_events AS s
JOIN employees AS e USING (employee_id)
WHERE s.email_category IN ('Phishing', 'Malware')
  AND s.user_action IN ('Clicked Link', 'Opened Attachment')
GROUP BY e.employee_id, e.employee_name, TRIM(e.department)
HAVING COUNT(*) > 1
ORDER BY interactions DESC;

-- D5. Which sender domains and subject themes were most successful at getting employees to click?

SELECT
  sender_domain,
  COUNT(*) AS malicious_emails,
  SUM(user_action IN ('Clicked Link', 'Opened Attachment')) AS clicked_or_opened,
  ROUND(
    100 * SUM(user_action IN ('Clicked Link', 'Opened Attachment')) / COUNT(*),
    1
  ) AS click_rate_pct
FROM email_security_events
WHERE email_category IN ('Phishing', 'Malware')
GROUP BY sender_domain
ORDER BY click_rate_pct DESC;

-- D6.How long did employees take to report malicious emails compared with how quickly others clicked them?

SELECT
  user_action,
  COUNT(*) AS email_count,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, received_timestamp, action_timestamp)), 1)
    AS average_minutes
FROM email_security_events
WHERE email_category IN ('Phishing', 'Malware')
  AND user_action IN ('Reported', 'Clicked Link', 'Opened Attachment')
  AND action_timestamp IS NOT NULL
GROUP BY user_action;


ISABELLA OMOLOYE 
SECTION E 1-3

CREATE DATABASE brightwave_logistics;
USE brightwave_logistics;

USE brightwave_logistics;
SHOW TABLES;

-- E. INCIDENT RESPONSE PERFORMANCE --
USE brightwave_logistics;

-- 1. How many incidents were logged, grouped by type and by severity? --

SELECT
    incident_type,
    COUNT(*) AS total_incidents
FROM incidents
GROUP BY incident_type
ORDER BY total_incidents DESC;

-- 2. How many incidents remain Open or In Progress? List the Critical and High incidents that are not yet closed.--

SELECT
    severity,
    COUNT(*) AS total_incidents
FROM incidents
GROUP BY severity
ORDER BY total_incidents DESC;

-- 3. For closed incidents with valid timestamps, what is the average, fastest and slowest time to close by severity? --

USE brightwave_logistics;

SELECT
    severity,

    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, reported_timestamp, closed_timestamp)) / 60,
        2
    ) AS average_hours_to_close,

    ROUND(
        MIN(TIMESTAMPDIFF(MINUTE, reported_timestamp, closed_timestamp)) / 60,
        2
    ) AS fastest_hours_to_close,

    ROUND(
        MAX(TIMESTAMPDIFF(MINUTE, reported_timestamp, closed_timestamp)) / 60,
        2
    ) AS slowest_hours_to_close

FROM incidents

WHERE LOWER(TRIM(incident_status)) = 'closed'
  AND reported_timestamp IS NOT NULL
  AND closed_timestamp IS NOT NULL
  AND closed_timestamp >= reported_timestamp

GROUP BY severity
ORDER BY severity;
