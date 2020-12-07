FROM alpine:latest

#environment

ENV TZ Europe/Berlin
ENV NODE_ENV production
ENV GHOST_CLI_VERSION 1.15.2
ENV GHOST_INSTALL /opt
ENV GHOST_CONTENT /opt/content
ENV GHOST_VERSION 3.39.1
ENV USER alpine
ENV URL http://localhost:2368
ENV DBHOST mariadb
ENV DBUSER root
ENV DBPASS root
ENV DBNAME root


RUN set -eux && apk update && apk add su-exec curl nodejs npm htop tzdata && apk upgrade && TZ=Europe/Berlin && cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >  /etc/timezone && apk del tzdata && rm -rvf /var/cache/apk/* /tmp/*
RUN addgroup -S ${USER} && adduser -S ${USER} -G ${USER} -s /bin/sh && chown ${USER}:${USER} /opt
RUN set -eux && npm install -g "ghost-cli@$GHOST_CLI_VERSION" && npm cache clean --force
RUN set -eux && su-exec ${USER} ghost install "$GHOST_VERSION" --db sqlite3 --no-prompt --no-stack --no-setup --no-start --no-enable --dir "$GHOST_INSTALL" &&\
  su-exec ${USER} npm cache clean --force && npm cache clean --force && rm -rf /tmp/* && rm -rf /home/${USER}/.cache/*
RUN set -eux && cd "${GHOST_INSTALL}" &&\
  su-exec ${USER} ghost config --ip 0.0.0.0 --port 2368 --no-prompt --url ${URL} --db mysql --dbhost mariadb --dbuser root --dbpass root --dbname ghost &&\
  su-exec ${USER} ghost config paths.contentPath "$GHOST_CONTENT"
RUN set -eux  && npm remove -g ghost ghost-cli && rm -rf /home/${USER}/.cache/*

WORKDIR ${GHOST_INSTALL}
USER alpine

ENTRYPOINT [ "sh" ]
EXPOSE 2368
CMD ["node", "current/index.js"]
