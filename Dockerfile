FROM debian:latest
#FROM postgres:alpine
MAINTAINER Past-AG

RUN apt -y update 
RUN apt -y install nginx nodejs postgresql npm
#RUN apk add --no-cache nginx nodejs npm

RUN pg_ctlcluster 13 main start
#RUN initdb -D /var/lib/postgres/data

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql -c "CREATE USER noodle WITH PASSWORD 'noodle';" &&\
    createdb -O noodle noodle

USER root
RUN npm install -g "https://github-registry-files.githubusercontent.com/453111396/a08c9380-85cd-11ec-8faa-e5a265b8af7f?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220204%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220204T155053Z&X-Amz-Expires=300&X-Amz-Signature=ce9cfcb0eebdd6564349a556d9e5169afaa8e649c7c335a97ddbcb8596b5c889&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=453111396&response-content-disposition=filename%3Dnoodle_backend-0.0.1-npm.tgz&response-content-type=application%2Foctet-stream"

EXPOSE 3000
CMD ["/bin/sh", "-c", "/etc/init.d/postgresql start && noodleBackend"]
