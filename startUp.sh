nginx
su postgres -c "pg_ctl start -D /var/lib/postgresql/data && NODE_ENV='production' npm start"
