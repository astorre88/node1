use Mix.Config

config :amqp,
  mq_url: "amqp://guest:guest@rabbit"

config :nadia,
  token: "${BOT_TOKEN}",
  telegram_channel_id: "${TELEGRAM_CHANNEL_ID}"
