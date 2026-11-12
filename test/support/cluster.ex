defmodule Elasticsearch.Test.Cluster do
  @moduledoc false

  use Elasticsearch.Cluster

  # Run the suite against the Req adapter with ELASTICSEARCH_API=req
  def api do
    case System.get_env("ELASTICSEARCH_API", "httpoison") do
      "req" -> Elasticsearch.API.Req
      _ -> Elasticsearch.API.HTTP
    end
  end

  def init(config) do
    url = Map.get(config, :url, "http://localhost:9200")

    {:ok,
     %{
       api: api(),
       json_library: Poison,
       url: url,
       username: "username",
       password: "password",
       indexes: %{
         posts: %{
           settings: "test/support/settings/posts.json",
           store: Elasticsearch.Test.Store,
           sources: [Post],
           bulk_page_size: 5000,
           bulk_wait_interval: 0
         }
       },
       default_options: default_options(api())
     }}
  end

  # Req rejects unknown options, so the AWS options are HTTPoison-only
  defp default_options(Elasticsearch.API.Req), do: []

  defp default_options(_api) do
    [
      aws: [
        region: "us-east-1",
        service: "es",
        access_key: "aws_access_key_id",
        secret: "aws_secret_access_key"
      ]
    ]
  end
end
