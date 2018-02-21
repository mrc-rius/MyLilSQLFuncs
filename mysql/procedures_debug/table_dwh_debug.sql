CREATE TABLE dwh_debug (
 debug_id INT PRIMARY KEY AUTO_INCREMENT,
 object_debugged VARCHAR(255) NOT NULL,
 debug_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 variable_name VARCHAR(200) NOT NULL,
 variable_value TEXT NOT NULL
);

