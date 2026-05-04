# Build stage
FROM fpco/stack-build:lts-22.27 AS build

WORKDIR /app

# Install dependencies first for better layer caching
COPY stack.yaml stack.yaml.lock package.yaml readlog.cabal /app/
RUN stack setup
RUN stack build --only-dependencies

# Copy source and build
COPY app /app/app
COPY src /app/src
RUN stack build --copy-bins --local-bin-path /app/bin

# Runtime stage
FROM debian:bookworm-slim AS runtime

# Runtime deps for GHC-built binaries
RUN apt-get update \
  && apt-get install -y --no-install-recommends libgmp10 ca-certificates libpq5 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/bin/readlog-exe /app/readlog-exe
COPY static /app/static

EXPOSE 3000

# Render provides PORT at runtime
ENV PORT=3000
ENV STATIC_DIR=/app/static

CMD ["/app/readlog-exe"]
