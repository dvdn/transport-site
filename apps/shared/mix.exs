defmodule Shared.MixProject do
  use Mix.Project

  def project do
    [
      app: :shared,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {Shared.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:timex, ">= 0.0.0"},
      {:httpoison, ">= 0.0.0"},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.0.0", only: :test},
      # Mint is used by our HttpStream shared component, so we add an explicity dependency
      {:mint, "~> 1.2"},
      # Finch is used for built-in streaming
      {:finch, "~> 0.8"},
      # Required for the ConditionalJSONEncoder shared component, but
      # there is probably a way to avoid that?
      {:phoenix, "~> 1.6.2"},
      # The global app config references Sentry.LoggerBackend. We add it in "shared"
      # as an implicit dependency, to ensure `Sentry.LoggerBackend` is always defined,
      # otherwise running tests for an individual umbrella sub-app will raise error.
      # A better way to achieve this will be to configure it at runtime, like described
      # in https://github.com/getsentry/sentry-elixir/pull/472.
      {:sentry, "~> 8.0.0"},
      # Similarly, Jason is configured as `json_library` by the main app, so it will
      # be required no matter what.
      {:jason, ">= 0.0.0"},
      {:ex_cldr_numbers, "~> 2.0"},
      {:yaml_elixir, "~> 2.7"},
      {:cachex, "~> 3.4"},
      {:ex_json_schema, "~> 0.9.1"}
    ]
  end
end
