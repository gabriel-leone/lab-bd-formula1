CREATE TABLE circuits (
    id INT,
    ref VARCHAR(100),
    name VARCHAR(255),
    location VARCHAR(255),
    country VARCHAR(100),
    lat numeric(9,6),
    lng numeric(9,6),
    alt int,
    url TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE constructors (
    id INT,
    ref VARCHAR(100),
    name VARCHAR(255),
    nationality VARCHAR(100),
    URL TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE drivers (
    id INT,
    ref VARCHAR(100),
    number VARCHAR(2),
    code VARCHAR(3),
    forename VARCHAR(100),
    surname VARCHAR(100),
    date_of_birth DATE,
    nationality VARCHAR(100),
    URL TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE countries (
    id INT,
    code VARCHAR(2),
    name VARCHAR(255),
    continent VARCHAR(2),
    wikipedia_link TEXT,
    keywords TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE airports (
    id INT,
    ident VARCHAR(10),
    type VARCHAR(100),
    name VARCHAR(255),
    lat_deg numeric(9,6),
    lng_deg numeric(9,6),
    elev_ft int,
    continent VARCHAR(2),
    iso_country VARCHAR(2),
    iso_region VARCHAR(10),
    city VARCHAR(100),
    scheduled_service VARCHAR(10),
    gps_code VARCHAR(10),
    iata_code VARCHAR(10),
    local_code VARCHAR(10),
    home_link TEXT,
    wikipedia_link TEXT,
    keywords TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE geocities15k (
    id BIGINT,
    name VARCHAR(100),
    ascii_name VARCHAR(100),
    alternate_names TEXT,
    lat numeric(9,6),
    lng numeric(9,6),
    feature_class VARCHAR(1),
    feature_code VARCHAR(10),
    country VARCHAR(2),
    cc2 VARCHAR(10),
    admin1_code BIGINT,
    admin2_code BIGINT,
    admin3_code BIGINT,
    admin4_code BIGINT,
    population BIGINT,
    elevation BIGINT,
    timezone VARCHAR(100),
    modification DATE,
    PRIMARY KEY (id)
);

CREATE TABLE status (
    id INT,
    status VARCHAR(100),
    PRIMARY KEY (id)
);

CREATE TABLE seasons (
    year INT,
    url TEXT,
    PRIMARY KEY (year)
);

CREATE TABLE races (
    id INT,
    year INT,
    round INT,
    circuit_id INT,
    name VARCHAR(100),
    date DATE,
    time TIME,
    url TEXT,
    PRIMARY KEY (id),
    CONSTRAINT fk_circuit FOREIGN KEY (circuit_id) REFERENCES circuits(id)
);

CREATE TABLE driver_standings (
    id INT,
    race_id INT,
    driver_id INT,
    points NUMERIC,
    position INT,
    position_text VARCHAR(3),
    wins INT,
    PRIMARY KEY (id),
    CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES races(id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

CREATE TABLE qualifying (
    id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    position INT,
    q1 INTERVAL,
    q2 INTERVAL,
    q3 INTERVAL,
    PRIMARY KEY (id),
    CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES races(id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES drivers(id),
    CONSTRAINT fk_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(id)
);

CREATE TABLE pitstops (
    race_id INT,
    driver_id INT,
    stop INT,
    lap INT,
    time TIME,
    duration INTERVAL,
    milliseconds BIGINT,
    PRIMARY KEY (race_id, driver_id, stop),
    CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES races(id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

CREATE TABLE laptimes (
    race_id INT,
    driver_id INT,
    lap INT,
    position INT,
    time INTERVAL,
    milliseconds BIGINT,
    PRIMARY KEY (race_id, driver_id, lap),
    CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES races(id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES drivers(id)
);

CREATE TABLE results (
    id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    grid INT,
    position INT,
    position_text VARCHAR(3),
    position_order INT,
    points NUMERIC,
    laps INT,
    time VARCHAR(11),
    milliseconds BIGINT,
    fastest_lap INT,
    rank INT,
    fastest_lap_time INTERVAL,
    fastest_lap_speed VARCHAR(7),
    status_id INT,
    PRIMARY KEY (id),
    CONSTRAINT fk_race FOREIGN KEY (race_id) REFERENCES races(id),
    CONSTRAINT fk_driver FOREIGN KEY (driver_id) REFERENCES drivers(id),
    CONSTRAINT fk_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(id),
    CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES status(id)
);

\copy circuits FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\circuits.csv' WITH (FORMAT csv, HEADER true);

\copy drivers FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\drivers.csv' WITH (FORMAT csv, HEADER true);

\copy constructors FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\constructors.csv' WITH (FORMAT csv, HEADER true);

\copy countries FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\countries.csv' WITH (FORMAT csv, HEADER true);

CREATE TABLE temp_airports (
    id INT,
    ident VARCHAR(10),
    type VARCHAR(100),
    name VARCHAR(255),
    latitude_deg numeric(9,6),
    longitude_deg numeric(9,6),
    elevation_ft int,
    continent VARCHAR(2),
    iso_country VARCHAR(2),
    iso_region VARCHAR(10),
    municipality VARCHAR(100),
    scheduled_service VARCHAR(10),
    icao_code VARCHAR(10),
    iata_code VARCHAR(10),
    gps_code VARCHAR(10),
    local_code VARCHAR(10),
    home_link VARCHAR(255),
    wikipedia_link VARCHAR(255),
    keywords TEXT
);

\copy temp_airports FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\airports.csv' WITH (FORMAT csv, HEADER true);

INSERT INTO airports (id, ident, type, name, lat_deg, lng_deg, elev_ft, continent, iso_country, iso_region, city, scheduled_service, iata_code, gps_code, local_code, home_link, wikipedia_link, keywords)
SELECT id, ident, type, name, latitude_deg, longitude_deg, elevation_ft, continent, iso_country, iso_region, municipality, scheduled_service, iata_code, gps_code, local_code, home_link, wikipedia_link, keywords
FROM temp_airports;

DROP TABLE temp_airports cascade;

CREATE TABLE temp_cities (
    id INT,
    name VARCHAR(100),
    ascii_name VARCHAR(100),
    alternate_names TEXT,
    lat numeric(9,6),
    lng numeric(9,6),
    feature_class VARCHAR(1),
    feature_code VARCHAR(10),
    country VARCHAR(2),
    cc2 VARCHAR(100),
    admin1_code VARCHAR(20),
    admin2_code VARCHAR(20),
    admin3_code VARCHAR(20),
    admin4_code VARCHAR(20),
    population BIGINT,
    elevation INT,
    dem VARCHAR(100),
    timezone VARCHAR(100),
    modification DATE
);

\copy temp_cities FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\Cities15000.tsv' WITH (FORMAT text, DELIMITER E'\t', NULL '');

INSERT INTO geocities15k (id, name, ascii_name, alternate_names, lat, lng, feature_class, feature_code, country, cc2, admin1_code, admin2_code, admin3_code, admin4_code, population, elevation, timezone, modification)
SELECT
    id,
    name,
    ascii_name,
    alternate_names,
    lat,
    lng,
    feature_class,
    feature_code,
    country,
    cc2,
    CASE WHEN admin1_code ~ E'^\\d+$' THEN admin1_code::BIGINT ELSE NULL END,
    CASE WHEN admin2_code ~ E'^\\d+$' THEN admin2_code::BIGINT ELSE NULL END,
    CASE WHEN admin3_code ~ E'^\\d+$' THEN admin3_code::BIGINT ELSE NULL END,
    CASE WHEN admin4_code ~ E'^\\d+$' THEN admin4_code::BIGINT ELSE NULL END,
    population,
    elevation,
    timezone,
    modification
FROM temp_cities;

DROP TABLE temp_cities;

\copy status FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\status.csv' WITH (FORMAT csv, HEADER true);

\copy seasons FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\seasons.csv' WITH (FORMAT csv, HEADER true);

\copy races FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\races.csv' WITH (FORMAT csv, HEADER true);

CREATE TABLE temp_races (
    id INT,
    year INT,
    round INT,
    circuit_id INT,
    name VARCHAR(100),
    date DATE,
    time TIME,
    url TEXT,
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME,
    sprint_date DATE,
    sprint_time TIME
);

\copy temp_races FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\races.csv' WITH (FORMAT csv, HEADER true, NULL '\N');

INSERT INTO races (id, year, round, circuit_id, name, date, time, url)
SELECT id, year, round, circuit_id, name, date, time, url
FROM temp_races;

DROP TABLE temp_races;

\copy driver_standings FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\driver_Standings.csv' WITH (FORMAT csv, HEADER true);

\copy qualifying FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\qualifying.csv' WITH (FORMAT csv, HEADER true, NULL '\N', QUOTE '"', ESCAPE '\');

CREATE TABLE temp_qualifying (
    id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    position INT,
    q1 TEXT,
    q2 TEXT,
    q3 TEXT
);

\copy temp_qualifying FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\qualifying.csv' WITH (FORMAT csv, HEADER true, NULL '\N', QUOTE '"', ESCAPE '\');

INSERT INTO qualifying (id, race_id, driver_id, constructor_id, number, position, q1, q2, q3)
SELECT
    id,
    race_id,
    driver_id,
    constructor_id,
    number,
    position,
    CASE WHEN q1 = '' THEN NULL ELSE '00:0' || q1 END::INTERVAL,
    CASE WHEN q2 = '' THEN NULL ELSE '00:0' || q2 END::INTERVAL,
    CASE WHEN q3 = '' THEN NULL ELSE '00:0' || q3 END::INTERVAL
FROM temp_qualifying;

DROP TABLE temp_qualifying;

CREATE TABLE temp_pitstops (
    race_id INT,
    driver_id INT,
    stop INT,
    lap INT,
    time TIME,
    duration TEXT,
    milliseconds BIGINT
);

\copy temp_pitstops FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\pit_Stops.csv' WITH (FORMAT csv, HEADER true, NULL '\N', QUOTE '"', ESCAPE '\');

INSERT INTO pitstops (race_id, driver_id, stop, lap, time, duration, milliseconds)
SELECT
    race_id,
    driver_id,
    stop,
    lap,
    time,
    CASE WHEN duration = '' THEN NULL ELSE '00:0' || duration END::INTERVAL,
    milliseconds
FROM temp_pitstops;

DROP TABLE temp_pitstops;

CREATE TABLE temp_laptimes (
    race_id INT,
    driver_id INT,
    lap INT,
    position INT,
    time TEXT,
    milliseconds BIGINT
);

\copy temp_laptimes FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\lap_Times.csv' WITH (FORMAT csv, HEADER true, NULL '\N', QUOTE '"', ESCAPE '\');

INSERT INTO laptimes (race_id, driver_id, lap, position, time, milliseconds)
SELECT
    race_id,
    driver_id,
    lap,
    position,
    time::INTERVAL,
    milliseconds
FROM temp_laptimes;

DROP TABLE temp_laptimes;

CREATE TABLE temp_results (
    id INT,
    race_id INT,
    driver_id INT,
    constructor_id INT,
    number INT,
    grid INT,
    position INT,
    position_text VARCHAR(3),
    position_order INT,
    points NUMERIC,
    laps INT,
    time VARCHAR(11),
    milliseconds BIGINT,
    fastest_lap INT,
    rank INT,
    fastest_lap_time TEXT,
    fastest_lap_speed VARCHAR(7),
    status_id INT
);

\copy temp_results FROM 'C:\Users\gabri\DataGripProjects\Lab-BD\results.csv' WITH (FORMAT csv, HEADER true, NULL '\N', QUOTE '"', ESCAPE '\');

INSERT INTO results (id, race_id, driver_id, constructor_id, number, grid, position, position_text, position_order, points, laps, time, milliseconds, fastest_lap, rank, fastest_lap_time, fastest_lap_speed, status_id)
SELECT
    id,
    race_id,
    driver_id,
    constructor_id,
    number,
    grid,
    position,
    position_text,
    position_order,
    points,
    laps,
    time,
    milliseconds,
    fastest_lap,
    rank,
    fastest_lap_time::INTERVAL,
    fastest_lap_speed,
    status_id
FROM temp_results;

DROP TABLE temp_results;
