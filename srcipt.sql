CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL UNIQUE,
    Code VARCHAR(10) NOT NULL UNIQUE
);

INSERT INTO countries (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases
WHERE Entity IS NOT NULL AND Code IS NOT NULL;

CREATE TABLE cases AS
SELECT
    t1.Year,
    t2.country_id,
    t1.Number_yaws,
    t1.polio_cases,
    t1.cases_guinea_worm,
    t1.Number_rabies,
    t1.Number_malaria,
    t1.Number_hiv,
    t1.Number_tuberculosis,
    t1.Number_smallpox,
    t1.Number_cholera_cases
FROM infectious_cases AS t1
JOIN countries AS t2
  ON t1.Entity = t2.Entity AND t1.Code = t2.Code;

ALTER TABLE cases
ADD COLUMN case_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE cases
ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

SELECT COUNT(*) FROM infectious_cases;

SELECT
    c.Entity,
    c.Code,
    AVG(CAST(NULLIF(t.Number_rabies, '') AS DECIMAL(10, 4))) AS Avg_Number_rabies,
    MIN(CAST(NULLIF(t.Number_rabies, '') AS DECIMAL(10, 4))) AS Min_Number_rabies,
    MAX(CAST(NULLIF(t.Number_rabies, '') AS DECIMAL(10, 4))) AS Max_Number_rabies,
    SUM(CAST(NULLIF(t.Number_rabies, '') AS DECIMAL(10, 4))) AS Sum_Number_rabies
FROM cases AS t
JOIN countries AS c
    ON t.country_id = c.country_id
WHERE NULLIF(t.Number_rabies, '') IS NOT NULL
GROUP BY c.Entity, c.Code
ORDER BY Avg_Number_rabies DESC
LIMIT 10;

SELECT
    Year,
    STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d') AS Start_Date_of_Year,
    CURDATE() AS Today_Date,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d'), CURDATE()) AS Years_Difference
FROM infectious_cases
LIMIT 10;

DELIMITER //

CREATE FUNCTION GetYearsDifference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE start_date DATE;
    DECLARE years_diff INT;

    SET start_date = STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d');
    SET years_diff = TIMESTAMPDIFF(YEAR, start_date, CURDATE());

    RETURN years_diff;
END //

DELIMITER ;

SELECT
    Year,
    GetYearsDifference(Year) AS Function_Calculated_Years_Difference
FROM infectious_cases
WHERE Year IS NOT NULL
LIMIT 10;