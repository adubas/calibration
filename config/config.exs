use Mix.Config

config :elixir_interview_starter, :timeouts,
  precheck1: 30_000,
  precheck2: 30_000,
  calibrate: 100_000

import_config "#{Mix.env()}.exs"
