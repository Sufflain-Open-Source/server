FROM ubuntu

WORKDIR "/root/.config"

COPY ["private/sufflain-config.json", "sufflain-config.json"]

COPY . /root/app

WORKDIR "/root/app"

RUN apt update && \
 apt install -y software-properties-common && \
 add-apt-repository ppa:plt/racket && \
 apt update && \
 apt install -y racket make && \
 bash ./resolve-deps.sh ; \
 make all

ENTRYPOINT ["/root/app/build/sfl", "--track"]