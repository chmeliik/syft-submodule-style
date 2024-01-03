FROM registry.access.redhat.com/ubi9/go-toolset:1.20@sha256:077f292da8bea9ce7f729489cdbd217dd268ce300f3e216cb1fffb38de7daeb9 AS build

WORKDIR /src/syft

COPY --chown=1001 syft/go.mod syft/go.sum .
RUN go mod download

COPY --chown=1001 . .
RUN ./build-syft-binary.sh

FROM scratch
# needed for version check HTTPS request
COPY --from=build /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/certs/ca-certificates.crt

# create the /tmp dir, which is needed for image content cache
WORKDIR /tmp

COPY --from=build /src/syft/dist/syft /syft

LABEL org.opencontainers.image.title="syft"
LABEL org.opencontainers.image.description="CLI tool and library for generating a Software Bill of Materials from container images and filesystems"
LABEL org.opencontainers.image.vendor="Anchore, Inc."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/anchore/syft/main/README.md"
LABEL io.artifacthub.package.logo-url="https://user-images.githubusercontent.com/5199289/136844524-1527b09f-c5cb-4aa9-be54-5aa92a6086c1.png"
LABEL io.artifacthub.package.license="Apache-2.0"

ENTRYPOINT ["/syft"]
