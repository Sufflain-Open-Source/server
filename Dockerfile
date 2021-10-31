# --- STAGE 1 ---
FROM ubuntu AS build
ENV CONFIG=/root/.config
ENV APP=/root/app

WORKDIR ${CONFIG}
COPY ["private/sufflain-config.json", "sufflain-config.json"]

COPY . ${APP}
WORKDIR ${APP}

RUN apt update && \
 apt install -y software-properties-common && \
 add-apt-repository ppa:plt/racket && \
 apt update && \
 apt install -y racket make && \
 bash ./resolve-deps.sh ; \
 make distribute

# --- STAGE 2 ---
FROM ubuntu
ENV CONFIG=/root/.config
ENV APP=/root/app
ENV BUILD=${APP}/build

RUN apt update && apt install -y openssl

WORKDIR ${CONFIG}
COPY ["private/sufflain-config.json", "sufflain-config.json"]

COPY --from=build "${APP}/dist" "${APP}/"

ENTRYPOINT ["/root/app/bin/sfl", "--track"]