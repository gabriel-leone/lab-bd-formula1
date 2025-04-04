CREATE TABLE circuits (
    circuit_id INT,
    circuit_ref VARCHAR(100),
    name VARCHAR(255),
    location VARCHAR(255),
    country VARCHAR(100),
    lat numeric(9,6),
    lng numeric(9,6),
    alt int,
    url VARCHAR,
    PRIMARY KEY (circuit_id)
);

CREATE TABLE constructors (
    constructor_id INT,
    constructor_ref VARCHAR(100),
    name VARCHAR(255),
    nationality VARCHAR(100),
    URL VARCHAR,
    PRIMARY KEY (constructor_id)
);

CREATE TABLE driver (
    driver_id INT,
    driver_ref VARCHAR(100),
    number INT, -- aqui talvez seja string
    code VARCHAR(3),
    forename VARCHAR(100),
    surname VARCHAR(100),
    date_of_birth DATE,
    nationality VARCHAR(100),
    URL VARCHAR,
    PRIMARY KEY (driver_id)
);

CREATE TABLE countries (
    country_id INT,
    code VARCHAR(2),
    name VARCHAR(255),
    continent VARCHAR(2),
    wikipedia_link VARCHAR,
    keywords VARCHAR,
    PRIMARY KEY (country_id)
    -- adicionar uma possível constraint de continente (são poucos valores)
    -- adicionar uma possível unicidade em code
)
