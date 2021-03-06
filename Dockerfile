FROM alpine:latest
MAINTAINER Past-AG

RUN apk add --no-cache nginx nodejs npm postgresql git

# Set up the nginx server
RUN mkdir /var/www/public
COPY nginx.conf /etc/nginx/nginx.conf
COPY noodle.conf /etc/nginx/sites-enabled/noodle.conf
COPY startUp.sh /usr/local/bin/startUp

# Build and Copy the Frontend
RUN git clone https://github.com/Software-Engineering-DHBW/noodle_frontend.git
WORKDIR /noodle_frontend
RUN git checkout MS5
RUN npm ci
RUN npm run build
RUN cp dist/* /var/www/public -r
WORKDIR /
RUN rm /noodle_frontend -r

# Set up the postgres-server
RUN mkdir /run/postgresql
RUN chown -R postgres:postgres /run/postgresql
USER postgres
RUN initdb -D /var/lib/postgresql/data

RUN pg_ctl start -D /var/lib/postgresql/data &&\
    psql -c "CREATE USER noodle WITH PASSWORD 'noodle';" &&\
    createdb -O noodle noodle

# Setup the noodle backend
USER root
ARG GITHUB_TOKEN

RUN echo //npm.pkg.github.com/:_authToken=${GITHUB_TOKEN} >> ~/.npmrc
RUN echo @software-engineering-dhbw:registry=https://npm.pkg.github.com/ >> ~/.npmrc
RUN npm install -g @software-engineering-dhbw/noodle_backend@0.0.2

USER postgres
RUN pg_ctl start -D /var/lib/postgresql/data &&\
    noodleBackend init

EXPOSE 80

USER root
CMD ["/bin/sh", "-c", "/usr/local/bin/startUp"]
