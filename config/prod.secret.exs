use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.

# You can generate a new secret by running:
#
#     mix phx.gen.secret
config :live_jobs_board, LiveJobsBoardWeb.Endpoint,
       secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :live_jobs_board, LiveJobsBoard.Repo,
       url: System.get_env("DATABASE_URL"),
       size: String.to_integer(System.get_env("POOL_SIZE") || "10")