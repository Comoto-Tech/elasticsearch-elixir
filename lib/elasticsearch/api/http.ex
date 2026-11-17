if Code.ensure_loaded?(HTTPoison) do
  defmodule Elasticsearch.API.HTTP do
    @moduledoc """
    An `Elasticsearch.API` implementation backed by
    [HTTPoison](https://hex.pm/packages/httpoison).

    Requires `:httpoison` in your dependencies:

        {:httpoison, "~> 2.0"}

    `:default_options` from the cluster config and per-request `opts` are
    passed to `HTTPoison.request/5`, so any HTTPoison/Hackney option works
    (e.g. `recv_timeout: 5_000` or `hackney: [pool: :my_pool]`).

    Responses are `HTTPoison.Response` structs and errors are
    `HTTPoison.Error` structs.
    """

    @behaviour Elasticsearch.API

    alias Elasticsearch.API.Request

    @impl true
    def request(config, method, url, data, opts) do
      method
      |> HTTPoison.request(
        Request.url(url, config),
        Request.body(data, config),
        Request.headers(config),
        opts ++ Map.get(config, :default_options, [])
      )
      |> Request.decode_response(config)
    end
  end
end
