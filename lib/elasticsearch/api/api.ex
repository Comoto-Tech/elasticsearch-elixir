defmodule Elasticsearch.API do
  @moduledoc """
  Behaviour for interacting with the Elasticsearch JSON API.

  Two implementations ship with this library, each backed by an optional
  dependency. Add whichever HTTP client you prefer to your deps:

    * `Elasticsearch.API.HTTP` - uses `:httpoison`
    * `Elasticsearch.API.Req` - uses `:req`

  `Elasticsearch.API.AWS` (AWS SigV4 signing) requires `:sigaws` and `:httpoison`.
  """

  @typedoc "An HTTP method"
  @type method :: :get | :put | :post | :delete | :head

  @typedoc "The URL to request from the API"
  @type url :: String.t()

  @typedoc "A payload of data to send, relevant to :put and :post requests"
  @type data :: binary | map | Keyword.t()

  @typedoc "A keyword list of options to pass to the underlying HTTP client"
  @type opts :: Keyword.t()

  @typedoc """
  The result of a request.

  On success, a response map or struct with a `:body` and either a
  `:status_code` (e.g. `HTTPoison.Response`) or a `:status`
  (e.g. `Req.Response`) key. On failure, the HTTP client's error term
  (e.g. `HTTPoison.Error` or `Req.TransportError`).
  """
  @type response ::
          {:ok, %{required(:body) => term, optional(atom) => term}}
          | {:error, term}

  @doc """
  Makes a request to an Elasticsearch JSON API URl using the given method.
  """
  @callback request(config :: Elasticsearch.Cluster.config(), method, url, data, opts) :: response
end
