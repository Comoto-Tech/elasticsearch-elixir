defmodule Elasticsearch.API.ReqTest do
  use ExUnit.Case

  alias Elasticsearch.API.Req, as: ReqAPI

  @host System.get_env("ELASTICSEARCH_HOST", "localhost")

  describe ".request/5" do
    test "respects absolute URLs" do
      assert {:ok, %Req.Response{status: 200, body: body}} =
               ReqAPI.request(%{}, :get, "http://#{@host}:9200/_cat/health", "", [])

      assert is_binary(body)
    end

    test "prepends the configured base URL and decodes JSON" do
      config = %{url: "http://#{@host}:9200", json_library: Poison}

      assert {:ok, %Req.Response{status: 200, body: %{"cluster_name" => _}}} =
               ReqAPI.request(config, :get, "/_cluster/health", "", [])
    end

    test "supports HEAD requests" do
      assert {:ok, %Req.Response{status: 200, body: ""}} =
               ReqAPI.request(%{url: "http://#{@host}:9200"}, :head, "/", "", [])
    end

    test "handles HTTP errors" do
      assert {:error, %Req.TransportError{}} =
               ReqAPI.request(%{}, :get, "http://#{@host}:9999/nonexistent", "", [])
    end

    test "handles timeouts" do
      assert {:error, %Req.TransportError{reason: :timeout}} =
               ReqAPI.request(
                 %{},
                 :get,
                 "http://#{@host}:9200/_cat/health",
                 "",
                 receive_timeout: 0
               )
    end

    test "per-request opts override default_options" do
      config = %{url: "http://#{@host}:9200", default_options: [receive_timeout: 0]}

      assert {:ok, %Req.Response{status: 200}} =
               ReqAPI.request(config, :get, "/_cat/health", "", receive_timeout: 5_000)
    end
  end

  describe "Elasticsearch functions" do
    test "unwrap Req responses" do
      config = %{api: ReqAPI, url: "http://#{@host}:9200", json_library: Poison}

      assert {:ok, %{"cluster_name" => _}} = Elasticsearch.get(config, "/_cluster/health")

      assert {:error, %Elasticsearch.Exception{}} =
               Elasticsearch.get(config, "/nonexistent-index/_doc/1")
    end
  end
end
