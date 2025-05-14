-- Exercício 1: Criação da visão materializada Aeroportos_Brasileiros

-- (a) Visão materializada para aeroportos brasileiros com dados de país e cidade
CREATE MATERIALIZED VIEW Aeroportos_Brasileiros AS
SELECT 
    a.name AS airport_name,
    a.lat_deg AS airport_lat,
    a.lng_deg AS airport_long,
    c.name AS country_name,
    c.continent AS country_continent,
    g.name AS city_name,
    g.population AS city_population
FROM 
    airports a
    JOIN countries c ON a.iso_country = c.code
    JOIN geocities15k g ON a.city = g.name AND g.country = c.code
WHERE 
    c.code = 'BR'
WITH DATA;

-- Teste 1.1: Contagem de tuplas na visão
SELECT COUNT(*) AS total_tuplas FROM Aeroportos_Brasileiros;

-- Teste 1.2: Exemplo de algumas tuplas
SELECT * FROM Aeroportos_Brasileiros LIMIT 5;

-- Exercício 2: Criação das visões Aeroportos_sem_cidades, Cidades_brasileiras e Aeroportos_Cidades_Proximas

-- Ativar extensões necessárias para Earth_Distance
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- Visão 2.1: Aeroportos_sem_cidades
CREATE VIEW Aeroportos_sem_cidades AS
SELECT 
    a.name AS airport_name,
    a.lat_deg AS airport_lat,
    a.lng_deg AS airport_long,
    a.iso_country
FROM 
    airports a
WHERE 
    a.iso_country = 'BR'
    AND a.city NOT IN (
        SELECT name 
        FROM geocities15k 
        WHERE country = 'BR'
    );

-- Visão 2.2: Cidades_brasileiras
CREATE VIEW Cidades_brasileiras AS
SELECT 
    g.name AS city_name,
    g.population,
    g.lat,
    g.lng
FROM 
    geocities15k g
WHERE 
    g.country = 'BR'
    AND g.population >= 100000;

-- Visão 2.3: Aeroportos_Cidades_Proximas
CREATE VIEW Aeroportos_Cidades_Proximas AS
SELECT 
    a.airport_name,
    c.city_name,
    c.population,
    earth_distance(
        ll_to_earth(a.airport_lat, a.airport_long),
        ll_to_earth(c.lat, c.lng)
    ) / 1000 AS distance_km
FROM 
    Aeroportos_sem_cidades a
    CROSS JOIN Cidades_brasileiras c
WHERE 
    earth_distance(
        ll_to_earth(a.airport_lat, a.airport_long),
        ll_to_earth(c.lat, c.lng)
    ) / 1000 <= 10
ORDER BY 
    a.airport_name, distance_km;

-- Teste 2.1: Verificação de Aeroportos_sem_cidades
SELECT * FROM Aeroportos_sem_cidades LIMIT 5;

-- Teste 2.2: Verificação de Cidades_brasileiras
SELECT * FROM Cidades_brasileiras LIMIT 5;

-- Teste 2.3: Verificação de Aeroportos_Cidades_Proximas
SELECT * FROM Aeroportos_Cidades_Proximas LIMIT 5;

-- Exercício 3: Criação da visão Circuitos_completa

CREATE VIEW Circuitos_completa AS
SELECT 
    c.name AS circuit_name,
    c.location,
    c.country AS circuit_country,
    co.code AS country_code,
    co.continent
FROM 
    circuits c
    LEFT JOIN countries co ON c.country = co.name;

-- Teste 3.1: Verificação de Circuitos_completa
SELECT * FROM Circuitos_completa LIMIT 5;

-- Teste 3.2: Contagem de tuplas
SELECT COUNT(*) AS total_tuplas FROM Circuitos_completa;

-- Exercício 4: Criação da visão Problemas_circuitos

CREATE VIEW Problemas_circuitos AS
SELECT 
    c.name AS circuit_name,
    c.location,
    c.country AS circuit_country
FROM 
    circuits c
WHERE 
    c.country NOT IN (
        SELECT name 
        FROM countries
    );

-- Teste 4.1: Verificação de Problemas_circuitos
SELECT * FROM Problemas_circuitos;

-- Teste 4.2: Contagem de tuplas
SELECT COUNT(*) AS total_tuplas FROM Problemas_circuitos;

-- Exercício 5: Criação da visão Correção_circuitos e atualização de países

-- Visão Correção_circuitos
CREATE VIEW Correção_circuitos AS
SELECT 
    c.name AS circuit_name,
    c.location,
    c.country AS circuit_country
FROM 
    circuits c
WHERE 
    c.country NOT IN (
        SELECT name 
        FROM countries
    );

-- Teste 5.1: Verificação de Correção_circuitos
SELECT * FROM Correção_circuitos;

-- Atualização 5.2: Correção dos nomes dos países
UPDATE circuits
SET country = 'Brasil'
WHERE country = 'Brazil';

UPDATE circuits
SET country = 'México'
WHERE country = 'Mexico';

UPDATE circuits
SET country = 'United Arab Emirates'
WHERE country = 'UAE';

-- Teste 5.3: Verificação após atualizações
SELECT name, location, country
FROM circuits
WHERE country IN ('Brasil', 'México', 'United Arab Emirates');