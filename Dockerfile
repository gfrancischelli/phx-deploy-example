FROM elixir:1.11.3-alpine AS build

# This args allow us to pass environment variables to docker build
# docker build . DATABASE_URL="...""
# Or directly if the variable is already set on your machine
# export DATABASE_URL="..." &&a docker build . --build-arg DATABASE_URL
ARG DATABASE_URL
ARG SECRET_KEY_BASE

# install build dependencies
RUN apk add --no-cache build-base npm git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

## TODO ENVIRONMENT VARIABLES

# install mix dependencies
COPY mix.exs mix.lock ./
COPY apps/example/mix.exs ./apps/example/
COPY apps/example_web/mix.exs ./apps/example_web/

COPY config config
RUN mix do deps.get, deps.compile

RUN ls apps/example_web

WORKDIR /app/apps/example_web

# build assets
COPY apps/example_web/assets/package.json apps/example_web/assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets --progress=false --no-audit --loglevel=error

COPY apps/example_web/priv priv
COPY apps/example_web/assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

WORKDIR /app

# compile and build release
COPY apps/example/lib ./apps/example/lib
COPY apps/example_web/lib ./apps/example_web/lib

# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/example_umbrella ./

ENV HOME=/app

CMD ["bin/example_umbrella", "start"]
