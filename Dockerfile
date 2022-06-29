FROM --platform=$BUILDPLATFORM nixos/nix AS build

WORKDIR /usr/src/saysthbot
COPY . .
RUN echo -e "experimental-features = nix-command flakes\nfilter-syscalls = false" >> /etc/nix/nix.conf
ARG TARGETPLATFORM
RUN nix build $(if [[ "$TARGETPLATFORM" == linux/arm64 ]]; then echo ".#packages.x86_64-linux.pkgsCross.aarch64-multiplatform.saysthbot-reborn"; fi)
RUN echo $(readlink -f result) > nix-path && nix copy --to file:///nix-cache/ $(cat nix-path)

FROM nixos/nix
COPY --from=build /nix-cache /nix-cache
COPY --from=build /usr/src/saysthbot/nix-path ./
RUN echo -e "experimental-features = nix-command flakes\nrequire-sigs = false" >> /etc/nix/nix.conf
RUN nix copy --from file:///nix-cache/ $(cat nix-path)
ENV TGBOT_TOKEN="" DATABASE_URI="" WRAPPER=""
CMD ["-c", "${WRAPPER} $(cat nix-path)/bin/saysthbot-reborn ${OPTIONS}"]
ENTRYPOINT [ "/bin/sh" ]
