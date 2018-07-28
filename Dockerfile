FROM elixir:1.5-slim AS distillery

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mix local.hex --force && \
    mix local.rebar --force

RUN mkdir app
WORKDIR /app

ENV MIX_ENV=prod

COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

RUN mix deps.get --only prod
RUN mix deps.compile

COPY . /app

RUN mix compile && \
    mix release --verbose

FROM erlang:20-slim

ENV LANG=C.UTF-8 MIX_ENV=prod REPLACE_OS_VARS=true

WORKDIR /app
COPY --from=distillery /app/_build/prod/rel/node1/ .

CMD ["bin/node1", "foreground"]
