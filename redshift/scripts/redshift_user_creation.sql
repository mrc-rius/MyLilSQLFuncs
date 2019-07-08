CREATE GROUP diwip_users; -- WITH USER tamas_faludi, moshe_zaraf;

CREATE USER tamas_faludi WITH PASSWORD 'Tamas_Faludi_2019' in group diwip_users;
CREATE USER moshe_zaraf WITH PASSWORD 'Moshe_Zaraf_2019' in group diwip_users;

grant usage on schema diwip_dw,raw_data to GROUP diwip_users;
grant select on all tables in schema diwip_dw,raw_data to GROUP diwip_users;

ALTER DEFAULT PRIVILEGES IN SCHEMA diwip_dw,raw_data GRANT SELECT ON TABLES TO GROUP diwip_users;