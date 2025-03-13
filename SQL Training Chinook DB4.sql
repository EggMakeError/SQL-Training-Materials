CREATE DATABASE IF NOT EXISTS brazilianstates; 

USE brazil;

SHOW TABLES;

CHECK TABLE brazilian_states;
REPAIR TABLE brazilian_states;

-- Step 2: Create the table
DROP TABLE IF EXISTS brazilian_states;

CREATE TABLE IF NOT EXISTS brazilian_states (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    abbreviation VARCHAR(10),
    zip_code VARCHAR(10)
);

-- Step 3: Load the CSV file into MySQL
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'Z:/New folder/br_state_codes.csv'
INTO TABLE brazilian_states
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  -- or '\n' based on your file type
IGNORE 1 LINES
(subdivision, name, postalCode_ranges)
SET 
    abbreviation = subdivision,
    zip_code = SUBSTRING_INDEX(SUBSTRING_INDEX(postalCode_ranges, ' ', 1), '-', 1),
    name = TRIM(name);



SELECT * FROM brazilian_states