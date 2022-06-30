FROM --platform=$BUILDPLATFORM nixos/nix:2.9.2 AS build

WORKDIR /usr/src/saysthbot
COPY . .
RUN echo -e "experimental-features = nix-command flakes\nfilter-syscalls = false" >> /etc/nix/nix.conf
ARG TARGETPLATFORM
RUN nix build $(if [[ "$TARGETPLATFORM" == linux/arm64 ]]; then echo ".#packages.x86_64-linux.pkgsCross.aarch64-multiplatform.saysthbot-reborn"; fi)
RUN echo $(readlink -f result) > nix-path && mkdir nix-store && mv $(nix-store -qR $(readlink -f result)) nix-store/

FROM alpine
COPY --from=build /usr/src/saysthbot/nix-path ./
COPY --from=build /usr/src/saysthbot/nix-store /nix/store
ENV TGBOT_TOKEN="" DATABASE_URI="" WRAPPER=""
CMD ["-c", "${WRAPPER} $(cat nix-path)/bin/saysthbot-reborn ${OPTIONS}"]
ENTRYPOINT [ "/bin/sh" ]
