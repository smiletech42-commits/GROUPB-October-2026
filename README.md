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
