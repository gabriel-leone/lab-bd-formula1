CREATE TABLE circuits (
    id INT,
    ref VARCHAR(100),
    name VARCHAR(255),
    location VARCHAR(255),
    country VARCHAR(100),
    lat numeric(9,6),
    lng numeric(9,6),
    alt int,
    url VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE constructors (
    id INT,
    ref VARCHAR(100),
    name VARCHAR(255),
    nationality VARCHAR(100),
    URL VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE drivers (
    id INT,
    ref VARCHAR(100),
    number INT, -- aqui talvez seja string
    code VARCHAR(3),
    forename VARCHAR(100),
    surname VARCHAR(100),
    date_of_birth DATE,
    nationality VARCHAR(100),
    URL VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE countries (
    id INT,
    code VARCHAR(2),
    name VARCHAR(255),
    continent VARCHAR(2),
    wikipedia_link VARCHAR(255),
    keywords VARCHAR(255),
    PRIMARY KEY (id)
    -- adicionar uma possível constraint de continente (são poucos valores)
    -- adicionar uma possível unicidade em code
);

CREATE TABLE airports (
    id INT,
    ident VARCHAR(4),
    type VARCHAR(100), -- colocar constraint dos tipos
    name VARCHAR(255),
    lat_deg numeric(9,6),
    lng_deg numeric(9,6),
    elev_ft int,
    continent VARCHAR(2), -- colocar constraint de continentes
    iso_country VARCHAR(2),
    iso_region VARCHAR(5), -- colocar constraint do formato "US-NY"
    city VARCHAR(100),
    scheduled_service VARCHAR(3), -- colocar constraint yes or no
    gps_code VARCHAR(4),
    iata_code VARCHAR(3),
    local_code VARCHAR(4),
    home_link VARCHAR(255),
    wikipedia_link VARCHAR(255),
    keywords VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE geocities15k (
    id INT,
    name VARCHAR(100),
    ascii_name VARCHAR(100),
    alternate_names TEXT,
    lat numeric(9,6),
    lng numeric(9,6),
    feature_class VARCHAR(1),
    feature_code VARCHAR(4),
    country VARCHAR(2),
    cc2 INT,
    admin1_code INT,
    admin2_code INT,
    admin3_code INT,
    admin4_code INT,
    population BIGINT,
    elevation INT,
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
    url VARCHAR(255),
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
    url VARCHAR(255),
    PRIMARY KEY (id),
    CONSTRAINT fk_circuit FOREIGN KEY (circuit_id) REFERENCES circuits(id)
);

CREATE TABLE driver_standings (
    id INT,
    race_id INT,
    driver_id INT,
    points INT,
    position INT,
    position_text VARCHAR(2),
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
    time INTERVAL,
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
    position_text VARCHAR(2),
    position_order INT,
    points INT,
    laps INT,
    time VARCHAR(11),
    milliseconds BIGINT,
    fastest_lap INTERVAL,
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
