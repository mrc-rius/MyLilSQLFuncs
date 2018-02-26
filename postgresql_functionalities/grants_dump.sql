GRANT read_role to rdmpdwh1;
GRANT rdmpdwh1 to cdmpdwh1;

GRANT CONNECT ON DATABASE dwh to read_role;

GRANT SELECT ON ALL TABLES IN SCHEMA app TO read_role;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO read_role;

GRANT SELECT ON ALL SEQUENCES IN SCHEMA app TO read_role;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA audit TO read_role;

grant usage on schema app to read_role;
grant usage on schema audit to read_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT ON TABLES TO read_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA audit GRANT SELECT ON TABLES TO read_role;