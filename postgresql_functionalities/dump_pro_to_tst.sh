#! /bin/bash
mkdir /data/restore_dwh_test_data/ 2> /dev/null
pg_dump -c --format=c -U cdmpdwh1 -d dwh -h pgmaster -n business -n salesforce -n public > /data/restore_dwh_test_data/data.sql
echo "Data Backup: DONE"
pg_dumpall -U cdmpdwh1 -g -h pgmaster > /data/restore_dwh_test_data/users.sql
echo "Users Backup: DONE"
sed 's/NOBYPASSRLS//g' /data/restore_dwh_test_data/users.sql > /data/restore_dwh_test_data/users_clean.sql
echo "Parse User Backup: DONE"
psql -h pgmaster-tst -d dwh -U idmpdwh2 -f /data/restore_dwh_test_data/users_clean.sql
echo "Restore Users: DONE"
dropdb -h pgmaster-tst -U idmpdwh2  dwh
echo "Drop db: DONE"
pg_restore -C -d dwh -U idmpdwh2 -h pgmaster-tst /data/restore_dwh_test_data/data.sql
echo "RESTORE DATA: DONE"
rm /data/restore_dwh_test_data/*
echo "DROP BACKUP: DONE"
