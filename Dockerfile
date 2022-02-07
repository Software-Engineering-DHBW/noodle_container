FROM alpine:latest
MAINTAINER Past-AG

RUN apk add --no-cache nginx nodejs npm postgresql git

# Set up the nginx server
RUN mkdir /var/www/public
RUN echo "Hello World" > /var/www/public/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY noodle.conf /etc/nginx/sites-enabled/noodle.conf
COPY startUp.sh /usr/local/bin/startUp

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
RUN git clone https://github.com/Software-Engineering-DHBW/noodle_backend.git
WORKDIR /noodle_backend
RUN npm ci

#ARG GITHUB_TOKEN

#RUN echo //npm.pkg.github.com/:_authToken=${GITHUB_TOKEN} >> ~/.npmrc
#RUN echo @software-engineering-dhbw:registry=https://npm.pkg.github.com/ >> ~/.npmrc
#RUN npm install -g @software-engineering-dhbw/noodle_backend@0.0.1

USER postgres
RUN pg_ctl start -D /var/lib/postgresql/data &&\
    npm start init

EXPOSE 3000

USER root
CMD ["/bin/sh", "-c", "/usr/local/bin/startUp"]
