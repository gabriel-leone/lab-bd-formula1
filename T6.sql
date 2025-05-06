-- T6 - Triggers SQL Solution

-- Exercício 1
-- Trigger que verifica se a cidade de um aeroporto inserido/modificado existe na tabela GEOCITIES15K

CREATE OR REPLACE FUNCTION VerificaAeroporto()
RETURNS TRIGGER AS $$
DECLARE
    cidade_existe BOOLEAN;
BEGIN
    -- Verifica se a cidade existe na tabela GEOCITIES15K
    SELECT EXISTS(
        SELECT 1
        FROM geocities15k
        WHERE name = NEW.city
    ) INTO cidade_existe;

    -- Se a cidade não existe, lança uma exceção
    IF NOT cidade_existe THEN
        RAISE EXCEPTION 'Cidade não encontrada! Operação cancelada.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger TR_Airports
CREATE TRIGGER TR_Airports
BEFORE INSERT OR UPDATE OF city ON airports
FOR EACH ROW
EXECUTE FUNCTION VerificaAeroporto();

-- Testes para o Exercício 1

-- Teste de inserção com cidade que não existe
-- Este comando deve falhar
INSERT INTO airports (
    id, ident, type, name, lat_deg, lng_deg, elev_ft,
    continent, iso_country, iso_region, city,
    scheduled_service, gps_code, iata_code, local_code,
    home_link, wikipedia_link, keywords
)
VALUES (
    999999, 'TEST123', 'small_airport', 'Test Airport', 40.7128, -74.0060, 10,
    'NA', 'US', 'US-NY', 'CidadeInexistente',
    'no', 'TEST123', 'TST', 'TEST',
    'http://example.com', 'http://example.com/wiki', 'test,airport'
);

-- Teste de inserção com cidade que existe
-- Este comando deve ter sucesso
INSERT INTO airports (
    id, ident, type, name, lat_deg, lng_deg, elev_ft,
    continent, iso_country, iso_region, city,
    scheduled_service, gps_code, iata_code, local_code,
    home_link, wikipedia_link, keywords
)
VALUES (
    999999, 'TEST123', 'small_airport', 'Test Airport', 40.7128, -74.0060, 10,
    'SA', 'BR', 'BR-SP', 'São Carlos',
    'no', 'TEST123', 'TST', 'TEST',
    'http://example.com', 'http://example.com/wiki', 'test,airport'
);

-- Teste de atualização com cidade que não existe
-- Este comando deve falhar
UPDATE airports
SET city = 'CidadeInexistente'
WHERE id = 999999;

-- Teste de atualização com cidade que existe
-- Este comando deve ter sucesso
UPDATE airports
SET city = 'London'
WHERE id = 999999;

-- Limpa o teste
DELETE FROM airports WHERE id = 999999;

-- Exercício 2
-- Análise do script:
/*
O script cria uma tabela chamada Results_Status que armazena contagens de resultados por StatusID.
Ele insere as contagens iniciais contando os resultados existentes agrupados por StatusID.
Basicamente, é uma tabela de sumário que mantém a contagem de quantos resultados existem para cada status.
*/

-- Recriando a tabela para garantir que esteja correta:
DROP TABLE IF EXISTS Results_Status;

CREATE TABLE Results_Status (
    StatusID INTEGER PRIMARY KEY,
    Contagem INTEGER,
    FOREIGN KEY (StatusID) REFERENCES status(id)
);

INSERT INTO Results_Status
SELECT S.id, COUNT(*)
FROM status S
JOIN results R ON R.status_id = S.id
GROUP BY S.id, S.status;

-- Exercício 2 (a), (b), (c)
-- Função e trigger para atualizar contagens na tabela Results_Status


CREATE OR REPLACE FUNCTION AtualizaContagem()
RETURNS TRIGGER AS $$
DECLARE
    contagem_anterior INTEGER;
    contagem_atual INTEGER;
    contagem_inicial INTEGER;
BEGIN
    -- Para INSERT
    IF (TG_OP = 'INSERT') THEN
        -- Obtém a contagem atual antes da atualização
        SELECT Contagem INTO contagem_inicial
        FROM Results_Status
        WHERE StatusID = NEW.status_id;

        -- Incrementa a contagem para o status inserido
        UPDATE Results_Status
        SET Contagem = Contagem + 1
        WHERE StatusID = NEW.status_id
        RETURNING Contagem INTO contagem_atual;

        RAISE NOTICE 'StatusID: %, Contagem Inicial: %, Contagem Final: %',
            NEW.status_id, contagem_inicial, contagem_atual;

    -- Para DELETE
    ELSIF (TG_OP = 'DELETE') THEN
        -- Obtém a contagem atual antes da atualização
        SELECT Contagem INTO contagem_inicial
        FROM Results_Status
        WHERE StatusID = OLD.status_id;

        -- Decrementa a contagem para o status removido
        UPDATE Results_Status
        SET Contagem = Contagem - 1
        WHERE StatusID = OLD.status_id
        RETURNING Contagem INTO contagem_atual;

        RAISE NOTICE 'StatusID: %, Contagem Inicial: %, Contagem Final: %',
            OLD.status_id, contagem_inicial, contagem_atual;

    -- Para UPDATE (somente se status_id foi alterado)
    ELSIF (TG_OP = 'UPDATE' AND OLD.status_id <> NEW.status_id) THEN
        -- Obtém as contagens iniciais do status antigo
        SELECT Contagem INTO contagem_anterior
        FROM Results_Status
        WHERE StatusID = OLD.status_id;

        -- Obtém a contagem inicial do novo status
        SELECT Contagem INTO contagem_atual
        FROM Results_Status
        WHERE StatusID = NEW.status_id;

        -- Decrementa a contagem para o status anterior
        UPDATE Results_Status
        SET Contagem = Contagem - 1
        WHERE StatusID = OLD.status_id;

        -- Incrementa a contagem para o novo status
        UPDATE Results_Status
        SET Contagem = Contagem + 1
        WHERE StatusID = NEW.status_id;

        RAISE NOTICE 'StatusId Anterior: %, Contagem Inicial: %, Contagem Final: %',
            OLD.status_id, contagem_anterior, contagem_anterior - 1;
        RAISE NOTICE 'StatusId Atual: %, Contagem Inicial: %, Contagem Final: %',
            NEW.status_id, contagem_atual, contagem_atual + 1;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger TR_ResultsStatus
CREATE TRIGGER TR_ResultsStatus
AFTER INSERT OR UPDATE OR DELETE ON results
FOR EACH ROW
EXECUTE FUNCTION AtualizaContagem();

-- Exercício 2 (d)
-- Função e trigger para verificar se o StatusID não é negativo

CREATE OR REPLACE FUNCTION VerificaStatus()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o StatusID é negativo
    IF NEW.status_id < 0 THEN
        RAISE EXCEPTION 'StatusID Negativo! Operação cancelada.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger TR_Results
CREATE TRIGGER TR_Results
BEFORE INSERT OR UPDATE OF status_id ON results
FOR EACH ROW
EXECUTE FUNCTION VerificaStatus();

-- Testes para o Exercício 2

-- Testes para a letra (a) - INSERT
-- Inserção de um novo resultado
INSERT INTO results (
    id, race_id, driver_id, constructor_id, number, grid, position,
    position_text, position_order, points, laps, time, milliseconds,
    fastest_lap, rank, fastest_lap_time, fastest_lap_speed, status_id
)
VALUES (
    99999, 1000, 1, 1, 44, 1, 1, '1', 1, 25, 58, '+0.000s', 5400000,
    1, 1, '00:01:30.000', '220.0', 1
);

-- Testes para a letra (b) - DELETE
-- Remoção do resultado inserido
DELETE FROM results WHERE id = 99999;

-- Testes para a letra (c) - UPDATE
-- Primeiro inserimos novamente
INSERT INTO results (
    id, race_id, driver_id, constructor_id, number, grid, position,
    position_text, position_order, points, laps, time, milliseconds,
    fastest_lap, rank, fastest_lap_time, fastest_lap_speed, status_id
)
VALUES (
    99999, 1000, 1, 1, 44, 1, 1, '1', 1, 25, 58, '+0.000s', 5400000,
    1, 1, '00:01:30.000', '220.0', 1
);

-- Atualização do status_id
UPDATE results SET status_id = 2 WHERE id = 99999;

-- Testes para a letra (d) - Verificação de StatusID negativo
-- Este comando deve falhar
UPDATE results SET status_id = -1 WHERE id = 99999;

-- Limpeza final
DELETE FROM results WHERE id = 99999;