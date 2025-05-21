-- Trabalho T6 - Exercícios sobre Índices
-- Universidade de São Paulo - SCC-541 - Laboratório de Bases de Dados
-- Data: 21 de maio de 2025

-- Função Mede_Tempo (adaptada do enunciado para retornar apenas o tempo médio)
CREATE OR REPLACE FUNCTION Mede_Tempo(Q TEXT)
RETURNS BIGINT AS $$
DECLARE
  TIni TIMESTAMP;
  TFin TIMESTAMP;
  i DOUBLE PRECISION;
  Diff BIGINT;
BEGIN
  -- Registra o tempo inicial
  TIni := CLOCK_TIMESTAMP();
  FOR i IN 0..100 LOOP
    EXECUTE Q;
  END LOOP;
  -- Registra o tempo final
  TFin := CLOCK_TIMESTAMP();
  -- Calcula a diferença em milissegundos
  Diff := ROUND(EXTRACT(EPOCH FROM (TFin - TIni)) * 1000 / 100);
  RAISE NOTICE 'Tempo médio (ms): %', Diff;
  RETURN Diff;
END;
$$ LANGUAGE plpgsql;

-- Exercício 1: Recuperar a nacionalidade do piloto dado o nome exato (forename || ' ' || surname)
-- Consulta: SELECT nationality FROM drivers WHERE forename || ' ' || surname = 'Lewis Hamilton'

-- Passo 1: Testar a consulta sem índice
DO $$
BEGIN
    RAISE NOTICE 'Exercício 1: Testando consulta sem índice...';
END $$;

SELECT Mede_Tempo('
    SELECT nationality
    FROM drivers
    WHERE forename || '' '' || surname = ''Lewis Hamilton''
');

-- Passo 2: Criar índice B-tree
CREATE INDEX idx_driver_fullname_btree ON drivers USING btree ((forename || ' ' || surname));

-- Passo 3: Testar a consulta com índice
DO $$
BEGIN
    RAISE NOTICE 'Exercício 1: Testando consulta com índice B-tree...';
END $$;

SELECT Mede_Tempo('
    SELECT nationality
    FROM drivers
    WHERE forename || '' '' || surname = ''Lewis Hamilton''
');

-- Passo 4: Analisar o plano de execução
DO $$
BEGIN
    RAISE NOTICE 'Exercício 1: Analisando plano de execução...';
END $$;

EXPLAIN ANALYZE
SELECT nationality
FROM drivers
WHERE forename || ' ' || surname = 'Lewis Hamilton';

-- Exercício 2: Recuperar latitude, longitude e população de cidades brasileiras com padrão de nome
-- Consulta: SELECT lat, lng, population FROM geocities15k WHERE country = 'BR' AND name LIKE 'Sao%'

-- Passo 1: Testar a consulta sem índice
DO $$
BEGIN
    RAISE NOTICE 'Exercício 2: Testando consulta sem índice...';
END $$;

SELECT Mede_Tempo('
    SELECT lat, lng, population
    FROM geocities15k
    WHERE country = ''BR'' AND name LIKE ''Sao%''
');

-- Passo 2: Criar índice B-tree com INCLUDE e condição WHERE
CREATE INDEX idx_cities_country_name_btree ON geocities15k USING btree (country, name) INCLUDE (lat, lng, population)
WHERE country = 'BR';

-- Passo 3: Testar a consulta com índice
DO $$
BEGIN
    RAISE NOTICE 'Exercício 2: Testando consulta com índice B-tree...';
END $$;

SELECT Mede_Tempo('
    SELECT lat, lng, population
    FROM geocities15k
    WHERE country = ''BR'' AND name LIKE ''Sao%''
');

-- Passo 4: Analisar o plano de execução
DO $$
BEGIN
    RAISE NOTICE 'Exercício 2: Analisando plano de execução...';
END $$;

EXPLAIN ANALYZE
SELECT lat, lng, population
FROM geocities15k
WHERE country = 'BR' AND name LIKE 'Sao%';