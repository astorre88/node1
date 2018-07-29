use Mix.Config

if File.exists?("config/dev.local.exs") do
  import_config "dev.local.exs"
end
