CREATE DATABASE brightwave_logistics;
USE brightwave_logistics;

USE brightwave_logistics;
SHOW TABLES;

-- E. Incident Response Performance --
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