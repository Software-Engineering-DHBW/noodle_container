FROM alpine:latest
MAINTAINER Past-AG

RUN apk add --no-cache nginx nodejs npm postgresql

RUN mkdir /run/postgresql
RUN chown -R postgres:postgres /run/postgresql
USER postgres
RUN initdb -D /var/lib/postgresql/data

RUN pg_ctl start -D /var/lib/postgresql/data &&\
    psql -c "CREATE USER noodle WITH PASSWORD 'noodle';" &&\
    createdb -O noodle noodle

USER root
ARG GITHUB_TOKEN

RUN echo //npm.pkg.github.com/:_authToken=${GITHUB_TOKEN} >> ~/.npmrc
RUN echo @software-engineering-dhbw:registry=https://npm.pkg.github.com/ >> ~/.npmrc
RUN npm install -g @software-engineering-dhbw/noodle_backend@0.0.1

EXPOSE 3000

USER postgres
CMD ["/bin/sh", "-c", "pg_ctl start -D /var/lib/postgresql/data && noodleBackend"]
