-- Exercício 1

CREATE OR REPLACE FUNCTION Nome_Nacionalidade(nome_escuderia VARCHAR)
RETURNS TEXT AS $$
DECLARE
    nacionalidade TEXT;
BEGIN
    SELECT nationality INTO nacionalidade
    FROM constructors
    WHERE name = nome_escuderia;

    IF nacionalidade IS NULL THEN
        RETURN 'Escuderia não encontrada';
    END IF;

    RETURN nacionalidade;
END;
$$ LANGUAGE plpgsql;

-- Testando com uma construtora existente
SELECT Nome_Nacionalidade('Ferrari');

-- Testando com uma construtora inexistente
SELECT Nome_Nacionalidade('Fake Team');

-- Usando a função para listar a nacionalidade dos construtores de 5 pilotos
SELECT DISTINCT d.forename, d.surname, Nome_Nacionalidade(c.name) as team_nationality
FROM drivers d
JOIN results r ON d.id = r.driver_id
JOIN constructors c ON r.constructor_id = c.id
LIMIT 5;


-- Exercício 2

CREATE OR REPLACE FUNCTION Pilotos_Nacionalidade(nacionalidade_piloto VARCHAR)
RETURNS VOID AS $$
DECLARE
    piloto RECORD;
    contador INTEGER := 1;
BEGIN
    FOR piloto IN
        SELECT forename, surname
        FROM drivers
        WHERE nationality = nacionalidade_piloto
        ORDER BY surname, forename
    LOOP
        RAISE NOTICE '% Nome: % %', contador, piloto.forename, piloto.surname;
        contador := contador + 1;
    END LOOP;

    IF contador = 1 THEN
        RAISE NOTICE 'Nenhum piloto encontrado com nacionalidade %', nacionalidade_piloto;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Teste da função com uma nacionalidade que possui pilotos
SELECT Pilotos_Nacionalidade('British');

-- Teste com sua nacionalidade modificada do T2
SELECT Pilotos_Nacionalidade('BR');


-- Exercício 3

CREATE OR REPLACE PROCEDURE Cidade_Chamada(nome_cidade VARCHAR)
AS $$
DECLARE
    cidade RECORD;
    contador INTEGER := 0;
BEGIN
    -- Conta cidades com o nome fornecido
    SELECT COUNT(*) INTO contador
    FROM geocities15k
    WHERE name = nome_cidade;

    RAISE NOTICE 'Contagem: %|', contador;

    -- Lista cada cidade com o nome fornecido
    FOR cidade IN
        SELECT g.name, g.population, c.name as pais
        FROM geocities15k g
        JOIN countries c ON g.country = c.code
        WHERE g.name = nome_cidade
    LOOP
        RAISE NOTICE 'Nome: %, População: %, País: %',
                     cidade.name, cidade.population, cidade.pais;
    END LOOP;

    IF contador = 0 THEN
        RAISE NOTICE 'Nenhuma cidade encontrada com o nome %', nome_cidade;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Testes com cidades existentes
CALL Cidade_Chamada('York');
CALL Cidade_Chamada('São Carlos');

-- Teste com cidade inexistente
CALL Cidade_Chamada('Fake city');


-- Exercício 4

CREATE OR REPLACE FUNCTION Numero_vitorias(nome VARCHAR, sobrenome VARCHAR, ano INTEGER DEFAULT NULL)
RETURNS INTEGER AS $$
DECLARE
    vitorias INTEGER;
BEGIN
    IF ano IS NULL THEN
        -- Conta vitórias em todos os anos
        SELECT COUNT(*) INTO vitorias
        FROM results r
        JOIN drivers d ON r.driver_id = d.id
        WHERE d.forename = nome
          AND d.surname = sobrenome
          AND r.position = 1;
    ELSE
        -- Conta vitórias no ano especificado
        SELECT COUNT(*) INTO vitorias
        FROM results r
        JOIN drivers d ON r.driver_id = d.id
        JOIN races rc ON r.race_id = rc.id
        WHERE d.forename = nome
          AND d.surname = sobrenome
          AND rc.year = ano
          AND r.position = 1;
    END IF;

    RETURN COALESCE(vitorias, 0);
END;
$$ LANGUAGE plpgsql;

-- Teste com um piloto bem-sucedido (todos os anos)
SELECT Numero_vitorias('Lewis', 'Hamilton');

-- Teste com um piloto bem-sucedido (ano específico)
SELECT Numero_vitorias('Lewis', 'Hamilton', 2020);

-- Teste com um piloto que não tem vitórias
SELECT Numero_vitorias('Lance', 'Stroll');


-- Exercício 5

CREATE OR REPLACE FUNCTION Pais_Continente()
RETURNS TABLE (Nome VARCHAR, Continente VARCHAR) AS $$
DECLARE
    cur_paises CURSOR FOR
        SELECT name, continent
        FROM countries
        WHERE LENGTH(name) <= 15;
    pais_rec RECORD;
BEGIN
    OPEN cur_paises;

    LOOP
        FETCH cur_paises INTO pais_rec;
        EXIT WHEN NOT FOUND;

        Nome := pais_rec.name;
        Continente := pais_rec.continent;
        RETURN NEXT;
    END LOOP;

    CLOSE cur_paises;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE NOTICE 'Nenhum país encontrado com nome de até 15 caracteres';
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro desconhecido: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Contagem dos resultados
SELECT count(*) FROM Pais_Continente();

-- Mostra alguns resultados
SELECT * FROM Pais_Continente() LIMIT 10;


-- Exercício 6

CREATE OR REPLACE FUNCTION Valida_Volta(
    Nome_Autodromo VARCHAR,
    Pais_Autodromo VARCHAR,
    Ano INTEGER,
    Prenome_Piloto VARCHAR,
    Sobrenome_Piloto VARCHAR,
    Numero_da_Volta INTEGER
)
RETURNS TABLE (Id_Piloto INTEGER, Id_corrida INTEGER, Status INTEGER) AS $$
DECLARE
    piloto_id INTEGER;
    corrida_id INTEGER;
    autodromo_id INTEGER;
    ultima_volta INTEGER;
    esta_volta_existe BOOLEAN;
BEGIN
    -- Verifica se o piloto existe
    SELECT id INTO piloto_id
    FROM drivers
    WHERE forename = Prenome_Piloto AND surname = Sobrenome_Piloto;

    IF piloto_id IS NULL THEN
        Status := 3;
        RETURN NEXT;
        RETURN;
    END IF;

    -- Verifica se o circuito existe
    SELECT id INTO autodromo_id
    FROM circuits
    WHERE name = Nome_Autodromo AND country = Pais_Autodromo;

    IF autodromo_id IS NULL THEN
        Status := 4;
        RETURN NEXT;
        RETURN;
    END IF;

    -- Verifica se a corrida existe
    SELECT r.id INTO corrida_id
    FROM races r
    WHERE r.circuit_id = autodromo_id AND r.year = Ano;

    IF corrida_id IS NULL THEN
        Status := 5;
        RETURN NEXT;
        RETURN;
    END IF;

    -- Verifica se os dados da volta já existem
    SELECT EXISTS(
        SELECT 1
        FROM laptimes
        WHERE race_id = corrida_id AND driver_id = piloto_id AND lap = Numero_da_Volta
    ) INTO esta_volta_existe;

    -- Encontra o número da última volta para este piloto nesta corrida
    SELECT MAX(lap) INTO ultima_volta
    FROM laptimes
    WHERE race_id = corrida_id AND driver_id = piloto_id;

    -- Se o piloto ainda não tem voltas
    IF ultima_volta IS NULL THEN
        IF Numero_da_Volta = 1 THEN
            Status := 2;
            Id_Piloto := piloto_id;
            Id_corrida := corrida_id;
        ELSE
            Status := 6;
            Id_Piloto := NULL;
            Id_corrida := NULL;
        END IF;
        RETURN NEXT;
        RETURN;
    END IF;

    -- Se esta volta já existe
    IF esta_volta_existe THEN
        Status := 1;
        Id_Piloto := piloto_id;
        Id_corrida := corrida_id;
        RETURN NEXT;
        RETURN;
    END IF;

    -- Verifica se a volta anterior existe
    IF Numero_da_Volta = ultima_volta + 1 THEN
        Status := 0;
        Id_Piloto := piloto_id;
        Id_corrida := corrida_id;
    ELSE
        Status := 6;
        Id_Piloto := NULL;
        Id_corrida := NULL;
    END IF;
    RETURN NEXT;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            Status := 6;
            Id_Piloto := NULL;
            Id_corrida := NULL;
            RETURN NEXT;
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro desconhecido: %', SQLERRM;
            Status := 6;
            Id_Piloto := NULL;
            Id_corrida := NULL;
            RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Teste com dados válidos para a próxima volta de um piloto
SELECT * FROM Valida_Volta(
    'Bahrain International Circuit',
    'Bahrain',
    2020,
    'Lewis',
    'Hamilton',
    58
);

-- Teste com uma volta já existente
SELECT * FROM Valida_Volta(
    'Bahrain International Circuit',
    'Bahrain',
    2020,
    'Lewis',
    'Hamilton',
    30
);

-- Teste com uma corrida e piloto existentes, mas o piloto não correu esta corrida
SELECT * FROM Valida_Volta(
    'Phoenix street circuit',
    'USA',
    1990,
    'Lewis',
    'Hamilton',
    1
);

-- Teste com piloto inexistente
SELECT * FROM Valida_Volta(
    'Bahrain International Circuit',
    'Bahrain',
    2020,
    'Fake',
    'Driver',
    1
);

-- Teste com circuito inexistente
SELECT * FROM Valida_Volta(
    'Fake Circuit',
    'Fake Country',
    2020,
    'Lewis',
    'Hamilton',
    1
);

-- Teste com um circuito que não teve corrida neste ano
SELECT * FROM Valida_Volta(
    'Phoenix street circuit',
    'USA',
    2023,
    'Lewis',
    'Hamilton',
    1
);

-- Teste com uma volta que não teve volta anterior
SELECT * FROM Valida_Volta(
    'Bahrain International Circuit',
    'Bahrain',
    2020,
    'Lewis',
    'Hamilton',
    59
);