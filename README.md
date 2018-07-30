# Node1

This application is one part of the telegram<->web_front system.
It receives messages from custom Telegram channel and sends them to rabbit and vice versa.
Also this project contains docker-compose.yml which starts whole system.

## Usage

Build and start system
```bash
$ BOT_TOKEN=xxx TELEGRAM_CHANNEL_ID=xxx SECRET_KEY_BASE=xxx docker-compose -f docker-compose.yml up -d --build
```

Run migrations
```bash
$ docker exec -it $(docker ps | grep node1_app2_1 | awk '{print $1}') bin/node2 migrate
```

Stop
```bash
$ BOT_TOKEN=xxx TELEGRAM_CHANNEL_ID=xxx SECRET_KEY_BASE=xxx docker-compose -f docker-compose.yml down
```
