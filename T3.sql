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
)