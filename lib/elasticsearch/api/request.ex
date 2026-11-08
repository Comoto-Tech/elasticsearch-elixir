defmodule Elasticsearch.API.Request do
  @moduledoc false

  # Shared, HTTP-client-agnostic helpers for `Elasticsearch.API` implementations.

  @doc """
  Builds the full URL. Absolute URLs are respected; relative URLs are joined
  onto the configured base URL.
  """
  @spec url(String.t(), map) :: String.t()
  def url("http" <> _rest = url, _config), do: url
  def url(url, config), do: Path.join(config.url, url)

  @doc """
  Converts the request body into JSON, unless it has already been converted.
  If the data is empty, returns `""`.
  """
  @spec body(term, map) :: binary
  def body(data, _config) when is_binary(data), do: data

  def body(data, config) when is_map(data) and data != %{} do
    json_library(config).encode!(data)
  end

  def body(_data, _config), do: ""

  @doc """
  Default request headers: JSON content type, any configured default headers,
  and HTTP Basic credentials when `:username` and `:password` are configured.
  """
  @spec headers(map) :: [{String.t(), String.t()}]
  def headers(config) do
    headers = [{"Content-Type", "application/json"}] ++ Map.get(config, :default_headers, [])

    case config do
      %{username: username, password: password} ->
        [{"Authorization", "Basic " <> Base.encode64("#{username}:#{password}")} | headers]

      _ ->
        headers
    end
  end

  @doc """
  Decodes the response body from JSON into a map, if it looks like JSON.
  """
  @spec decode_response({:ok, map} | term, map) :: {:ok, map} | term
  def decode_response({:ok, %{body: body} = response}, config) do
    body = if json?(body), do: json_library(config).decode!(body), else: body
    {:ok, %{response | body: body}}
  end

  def decode_response(response, _config), do: response

  defp json?(str) when is_binary(str), do: str =~ ~r/^\{/ || str =~ ~r/^\[/
  defp json?(_), do: false

  @doc "The configured JSON library, defaulting to `Poison`."
  @spec json_library(map) :: module
  def json_library(%{json_library: json_library}), do: json_library
  def json_library(_config), do: Poison
end
