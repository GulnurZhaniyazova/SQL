CREATE DATABASE Customers_transactions;
SET SQL_SAFE_UPDATES = 0;
UPDATE customers SET Gender = NULL WHERE Gender = '';
SET SQL_SAFE_UPDATES = 0;
UPDATE customers SET Age = NULL WHERE Age = '';
ALTER TABLE Customers MODIFY Age INT NULL;
SELECT * FROM Customers;

CREATE TABLE Transactions
(
    date_new DATE,
    Id_check INT,
    ID_client INT,
    Count_products DECIMAL(10,3),
    Sum_payment DECIMAL(10,2)
);



TRUNCATE TABLE Transactions;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/TRANSACTIONS_final.csv'
INTO TABLE Transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM Transactions
LIMIT 10;

#1. Клиенты с непрерывной историей за год
SELECT
    t.ID_client,
    AVG(t.Sum_payment) AS avg_check,
    SUM(t.Sum_payment) / 12 AS avg_month_sum,
    COUNT(*) AS total_operations
FROM Transactions t
WHERE t.date_new >= '2015-06-01'
  AND t.date_new < '2016-06-01'
GROUP BY t.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12;

#2. Информация по месяцам
SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,
    AVG(Sum_payment) AS avg_check_month,
    COUNT(*) AS operations_count,
    COUNT(DISTINCT ID_client) AS clients_count,
    COUNT(*) / (
        SELECT COUNT(*)
        FROM Transactions
        WHERE date_new >= '2015-06-01'
          AND date_new < '2016-06-01'
    ) * 100 AS operations_share_percent,
    SUM(Sum_payment) / (
        SELECT SUM(Sum_payment)
        FROM Transactions
        WHERE date_new >= '2015-06-01'
          AND date_new < '2016-06-01'
    ) * 100 AS payment_share_percent
FROM Transactions
WHERE date_new >= '2015-06-01'
  AND date_new < '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;

##3
SELECT
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    IFNULL(c.Gender,'NA') AS gender,
    COUNT(DISTINCT t.ID_client) AS clients_count,
    SUM(t.Sum_payment) AS total_payment
FROM Transactions t
LEFT JOIN Customers c
ON t.ID_client = c.ID_client
WHERE t.date_new >= '2015-06-01'
AND t.date_new < '2016-06-01'
GROUP BY
    DATE_FORMAT(t.date_new, '%Y-%m'),
    IFNULL(c.Gender,'NA')
ORDER BY month, gender;

SELECT
    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    SUM(t.Sum_payment) AS total_payment,
    COUNT(*) AS operations_count
FROM Transactions t
LEFT JOIN Customers c
ON t.ID_client = c.ID_client
WHERE t.date_new >= '2015-06-01'
AND t.date_new < '2016-06-01'
GROUP BY age_group
ORDER BY age_group;

SELECT
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,

    CASE
        WHEN c.Age IS NULL THEN 'NA'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END AS age_group,

    AVG(t.Sum_payment) AS avg_check,
    SUM(t.Sum_payment) AS total_payment,
    COUNT(*) AS operations_count

FROM Transactions t
LEFT JOIN Customers c
ON t.ID_client = c.ID_client

WHERE t.date_new >= '2015-06-01'
AND t.date_new < '2016-06-01'

GROUP BY
    CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)),
    age_group

ORDER BY quarter, age_group;