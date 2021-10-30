FROM archlinux

WORKDIR "/root/.config"

COPY ["private/sufflain-config.json", "sufflain-config.json"]

COPY . /root/app

WORKDIR "/root/app"

RUN pacman -Sy && \ 
 pacman -S --noconfirm racket-minimal make && \ 
 bash ./resolve-deps.sh && \ 
 make

ENTRYPOINT ["/root/app/build/sfl", "--track"]