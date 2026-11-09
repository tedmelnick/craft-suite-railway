# syntax=docker/dockerfile:1

# ---- Stage 1: fetch pinned upstream release artifacts ----
# Versions are bare semver (no "v"); release tags are v${VER} and assets are
# ${repo}-web-${VER}.zip per upstream packaging convention.
FROM alpine:3.20 AS fetch

ARG PHOTOCRAFT_VERSION=0.5.0-main4
ARG LIGHTCRAFT_VERSION=0.18.0
ARG PDFCRAFT_VERSION=0.5.0-main2
ARG VECTORCRAFT_VERSION=0.21.0
ARG FILMCRAFT_VERSION=0.17.0
ARG EFFECTCRAFT_VERSION=0.22.0
# Additional ArtCraft-launcher apps. All but Craft Anything are built with the
# in-page agent API (see the *_URL args below); Craft Anything has no control
# channel to drive, so it's the plain upstream build.
ARG CADCRAFT_VERSION=0.17.0-main-fonts
ARG DECKCRAFT_VERSION=0.15.0-main-fonts
ARG GRIDCRAFT_VERSION=0.16.0-main-fonts
ARG SOUNDCRAFT_VERSION=0.17.0-main-agent-fonts
ARG CRAFT_ANYTHING_VERSION=0.3.0
ARG DESIGNCRAFT_VERSION=0.17.0-main-agent-fonts
ARG FIGCRAFT_VERSION=0.15.0-main-fonts
ARG MATERIALCRAFT_VERSION=0.1.3-main-agent-fonts
ARG TEXTURECRAFT_VERSION=0.3.1-main-agent-fonts
ARG WORDCRAFT_VERSION=0.15.1-main-fonts
# The PhotoCraft and PdfCraft web builds that ship the in-page agent APIs
# (window.photocraft / window.pdfcraft, incl. PdfCraft's form.* commands) are
# published from derekcheungsa/craft-suite-railway, not upstream. FilmCraft's
# upstream releases now ship window.filmcraft, so FILMCRAFT_URL is empty and
# the upstream build is used — they carry a "-main" version
# suffix and a commit-tagged asset.
ARG FILMCRAFT_URL=""
ARG PHOTOCRAFT_URL="https://github.com/derekcheungsa/craft-suite-railway/releases/download/photocraft-web-0.5.0-main4-0c72d95/photocraft-web-0.5.0-main4.zip"
ARG PDFCRAFT_URL="https://github.com/derekcheungsa/craft-suite-railway/releases/download/pdfcraft-web-0.5.0-main2-23f0675/pdfcraft-web-0.5.0-main2.zip"
# GridCraft and WordCraft builds with the in-page agent API (window.gridcraft /
# window.wordcraft) from upstream main, built by .github/workflows/build-craft-web.yml
# and published as releases here. Clear these (and restore the upstream release
# versions above) to go back to the plain upstream builds.
ARG GRIDCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/gridcraft-web-0.16.0-main-fonts-2c58c76/gridcraft-web-0.16.0-main-fonts.zip"
ARG WORDCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/wordcraft-web-0.15.1-main-fonts-4b0d399/wordcraft-web-0.15.1-main-fonts.zip"
# Builds with the agent API from upstream main (FigCraft, DeckCraft, CADCraft) or
# upstream main plus .github/craft-web-patches (DesignCraft, SoundCraft,
# MaterialCraft, TextureCraft), published as releases here by the same workflow.
ARG FIGCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/figcraft-web-0.15.0-main-fonts-8a7ebc2/figcraft-web-0.15.0-main-fonts.zip"
ARG DECKCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/deckcraft-web-0.15.0-main-fonts-c4674f2/deckcraft-web-0.15.0-main-fonts.zip"
ARG CADCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/cadcraft-web-0.17.0-main-fonts-909af5e/cadcraft-web-0.17.0-main-fonts.zip"
ARG DESIGNCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/designcraft-web-0.17.0-main-agent-fonts-49f6b85/designcraft-web-0.17.0-main-agent-fonts.zip"
ARG SOUNDCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/soundcraft-web-0.17.0-main-agent-fonts-ddeb7e7/soundcraft-web-0.17.0-main-agent-fonts.zip"
ARG MATERIALCRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/materialcraft-web-0.1.3-main-agent-fonts-767dd65/materialcraft-web-0.1.3-main-agent-fonts.zip"
ARG TEXTURECRAFT_URL="https://github.com/tedmelnick/craft-suite-railway/releases/download/texturecraft-web-0.3.1-main-agent-fonts-4be75a2/texturecraft-web-0.3.1-main-agent-fonts.zip"

RUN apk add --no-cache curl unzip gzip
WORKDIR /site

RUN set -eux; \
    fetch() { \
      repo="$1"; ver="$2"; override="${3:-}"; \
      if [ -n "$override" ]; then url="$override"; \
      else url="https://github.com/storytold/${repo}/releases/download/v${ver}/${repo}-web-${ver}.zip"; fi; \
      echo "fetching ${url}"; \
      curl -fsSL --retry 3 -o /tmp/app.zip "${url}"; \
      unzip -q /tmp/app.zip -d /tmp/app; \
      mv "/tmp/app/${repo}-web-${ver}" "/site/${repo}"; \
      rm -rf /tmp/app /tmp/app.zip; \
      printf '%s"%s":"v%s"' "${sep:-}" "$repo" "$ver" >> /tmp/versions.part; sep=","; \
    }; \
    fetch photocraft     "${PHOTOCRAFT_VERSION}" "${PHOTOCRAFT_URL}"; \
    fetch lightcraft     "${LIGHTCRAFT_VERSION}"; \
    fetch pdfcraft       "${PDFCRAFT_VERSION}" "${PDFCRAFT_URL}"; \
    fetch vectorcraft    "${VECTORCRAFT_VERSION}"; \
    fetch filmcraft      "${FILMCRAFT_VERSION}" "${FILMCRAFT_URL}"; \
    fetch effectcraft    "${EFFECTCRAFT_VERSION}"; \
    fetch cadcraft       "${CADCRAFT_VERSION}" "${CADCRAFT_URL}"; \
    fetch deckcraft      "${DECKCRAFT_VERSION}" "${DECKCRAFT_URL}"; \
    fetch gridcraft      "${GRIDCRAFT_VERSION}" "${GRIDCRAFT_URL}"; \
    fetch soundcraft     "${SOUNDCRAFT_VERSION}" "${SOUNDCRAFT_URL}"; \
    fetch craft-anything "${CRAFT_ANYTHING_VERSION}"; \
    fetch designcraft    "${DESIGNCRAFT_VERSION}" "${DESIGNCRAFT_URL}"; \
    fetch figcraft       "${FIGCRAFT_VERSION}" "${FIGCRAFT_URL}"; \
    fetch materialcraft  "${MATERIALCRAFT_VERSION}" "${MATERIALCRAFT_URL}"; \
    fetch texturecraft   "${TEXTURECRAFT_VERSION}" "${TEXTURECRAFT_URL}"; \
    fetch wordcraft      "${WORDCRAFT_VERSION}" "${WORDCRAFT_URL}"; \
    { printf '{'; cat /tmp/versions.part; printf '}\n'; } > /site/versions.json; \
    rm /tmp/versions.part

# Craft Relay bridge: static script served same-origin. Inject the script
# tags BEFORE precompressing, so index.html.gz matches the on-disk file.
# RELAY_URL may be absolute (https://relay.example) or relative ("/relay"),
# which resolves against the page origin through nginx's /relay/ proxy.
ARG RELAY_URL="/relay"
COPY bridge/ /site/bridge/
RUN printf 'window.CRAFT_RELAY = { url: "%s" };\n' "$RELAY_URL" > /site/bridge/config.js && \
    for f in /site/*/index.html; do \
      grep -q 'bridge/loader.js' "$f" || \
      sed -i 's#</body>#<script src="/bridge/config.js"></script><script src="/bridge/adapters.js"></script><script src="/bridge/loader.js" defer></script></body>#' "$f"; \
    done

# Precompress the heavy payloads once at build time; nginx serves the .gz
# copies via gzip_static instead of compressing on every request.
RUN find /site -type f \( -name '*.wasm' -o -name '*.js' -o -name '*.html' \) \
      -exec sh -c 'gzip -9 -c "$1" > "$1.gz"' _ {} \;

# ---- Stage 2: nginx serving the six apps + portal ----
FROM nginx:1.27-alpine

# Port nginx listens on, plus the relay proxy's upstream (host:port on
# Railway private networking — the platform injects PORT=8080 into the relay
# container) and the DNS resolver used to re-resolve it per request.
ENV PORT=8080
ARG RELAY_UPSTREAM="craft-relay.railway.internal:8080"
ENV RELAY_UPSTREAM=${RELAY_UPSTREAM}
ARG RESOLVER="[fd12::10]"
ENV RESOLVER=${RESOLVER}

COPY nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=fetch /site /usr/share/nginx/html
COPY portal/ /usr/share/nginx/html/

EXPOSE 8080
