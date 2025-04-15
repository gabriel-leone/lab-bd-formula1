-- Exercício 1

SELECT
    driver_id
    ,r.year as year
    ,sum(points) as total_points
FROM driver_standings as ds
JOIN races r on ds.race_id = r.id
GROUP BY driver_id, year
ORDER BY total_points desc;

-- Exercício 2

SELECT
    year
    ,count(*) as races_amount
FROM races
GROUP BY year
ORDER BY races_amount DESC;

-- Exercício 3

SELECT
    continent
    ,type
    ,count(*) as qty
FROM airports
GROUP BY continent, type
ORDER BY continent, type;

-- Exercício 4

ALTER TABLE QUALIFYING
ADD COLUMN "podium_position" VARCHAR(10);

UPDATE QUALIFYING
SET podium_position = 'Podium'
WHERE position IN (1, 2, 3);

-- Exercício 5

UPDATE drivers
SET nationality = 'BR'
WHERE nationality = 'Brazilian';

-- Exercício 6

SELECT
    concat(d.forename, ' ', d.surname) as name
    ,count(*) as pole_positions
FROM qualifying q
JOIN drivers d ON d.id = q.driver_id
WHERE q.position = 1
GROUP BY d.surname, d.forename
ORDER BY pole_positions DESC
LIMIT 1;

-- Exercício 7

SELECT
    countries.name as country
    ,count(DISTINCT cities.id) as qty_cities
    ,count(DISTINCT airports.id) as qty_airports
FROM countries
JOIN geocities15k cities ON cities.country = countries.code
JOIN airports ON airports.iso_country = countries.code
WHERE
    countries.id IN (
        SELECT DISTINCT country.id
        FROM circuits c
        JOIN countries country ON c.country = country.name
        )
GROUP BY countries.name;

-- Exercício 8

CREATE TABLE countries_v2 AS
SELECT * FROM countries;

DELETE FROM countries_v2
WHERE id IN (
    SELECT c.id
    FROM countries c
    WHERE c.code IN (
        SELECT iso_country
        FROM airports
        GROUP BY iso_country
        HAVING COUNT(*) >= 10
    )
);
