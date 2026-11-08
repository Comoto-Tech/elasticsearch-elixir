if Code.ensure_loaded?(Req) do
  defmodule Elasticsearch.API.Req do
    @moduledoc """
    An `Elasticsearch.API` implementation backed by [Req](https://hex.pm/packages/req).

    Requires `:req` in your dependencies:

        {:req, "~> 0.5"}

    ## Options

    `:default_options` from the cluster config and per-request `opts` are
    passed to `Req.request/1`, so any Req option works (e.g.
    `receive_timeout: 5_000`, `connect_options: [timeout: 5_000]`, or
    `finch: MyApp.Finch`). Per-request `opts` take precedence over
    `:default_options`.

    Req rejects options it does not recognize, so HTTPoison/Hackney options
    such as `recv_timeout` or `hackney: [...]` must not appear in
    `:default_options` when using this module.

    This module sets two defaults that differ from Req's own defaults, so its
    behaviour matches `Elasticsearch.API.HTTP`:

      * `retry: false` - Req's automatic retries are disabled. Re-enable them
        with e.g. `default_options: [retry: :transient]`.
      * `decode_body: false` - JSON bodies are decoded with the cluster's
        configured `:json_library` rather than by Req.

    Responses are `Req.Response` structs and errors are exceptions such as
    `Req.TransportError`.
    """

    @behaviour Elasticsearch.API

    alias Elasticsearch.API.Request

    @defaults [retry: false, decode_body: false]

    @impl true
    def request(config, method, url, data, opts) do
      @defaults
      |> Keyword.merge(Map.get(config, :default_options, []))
      |> Keyword.merge(opts)
      |> Keyword.merge(
        method: method,
        url: Request.url(url, config),
        body: Request.body(data, config),
        headers: Request.headers(config)
      )
      |> Req.request()
      |> Request.decode_response(config)
    end
  end
end
