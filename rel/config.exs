# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

# environment :dev do
#   # If you are running Phoenix, you should make sure that
#   # server: true is set and the code reloader is disabled,
#   # even in dev mode.
#   # It is recommended that you build with MIX_ENV=prod and pass
#   # the --env flag to Distillery explicitly if you want to use
#   # dev mode.
#   set dev_mode: true
#   set include_erts: false
#   set cookie: :"I/6_*<2/hDRUKeGkt!r|:yqju*z0(/n?OdP(EO!Mp_kxo]1UGKG]n13P8QfrAF]L"
# end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"A(/3Ta3J?RD?=I]x:7|,A|mr;~:|plcNv@f/zPa5=NpkG:sak8r4S@VULf3X<xy="
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :node1 do
  set version: current_version(:node1)
  set applications: [
    :runtime_tools
  ]
end

