defmodule Transport.Shared.SchemasTest do
  use Shared.CacheCase
  import Transport.Shared.Schemas

  @base_url "https://schema.data.gouv.fr"

  setup do
    setup_schemas_response()
    Mox.stub_with(Transport.Shared.Schemas.Mock, Transport.Shared.Schemas)
    :ok
  end

  test "transport_schemas" do
    assert ["etalab/schema-amenagements-cyclables", "etalab/schema-lieux-covoiturage", "etalab/schema-zfe"] ==
             Map.keys(transport_schemas())

    assert_cache_key_has_ttl("transport_schemas")
  end

  test "schemas_by_type" do
    assert ["etalab/schema-amenagements-cyclables", "etalab/schema-zfe"] == Map.keys(schemas_by_type("jsonschema"))
    assert ["etalab/schema-lieux-covoiturage"] == Map.keys(schemas_by_type("tableschema"))
  end

  test "read_latest_schema" do
    setup_schema_response("#{@base_url}/schemas/etalab/schema-zfe/0.7.2/schema.json")

    assert %{"foo" => "bar"} == read_latest_schema("etalab/schema-zfe")
    assert_cache_key_has_ttl("latest_schema_etalab/schema-zfe")

    setup_schema_response("#{@base_url}/schemas/etalab/schema-lieux-covoiturage/0.2.3/schema.json")

    assert %{"foo" => "bar"} == read_latest_schema("etalab/schema-lieux-covoiturage")
    assert_cache_key_has_ttl("latest_schema_etalab/schema-lieux-covoiturage")
  end

  describe "schema_url" do
    test "simple case" do
      assert "#{@base_url}/schemas/etalab/schema-zfe/0.7.2/schema.json" ==
               schema_url("etalab/schema-zfe", "latest")

      assert "#{@base_url}/schemas/etalab/schema-zfe/0.7.2/schema.json" ==
               schema_url("etalab/schema-zfe", "0.7.2")
    end

    test "with a custom schema filename" do
      assert "#{@base_url}/schemas/etalab/schema-amenagements-cyclables/0.3.3/schema_amenagements_cyclables.json" ==
               schema_url("etalab/schema-amenagements-cyclables", "latest")
    end

    test "makes sure schema and version are valid" do
      assert_raise KeyError, ~r(^key "foo" not found in), fn ->
        schema_url("foo", "latest")
      end

      assert_raise KeyError, "foo is not a valid version for etalab/schema-zfe", fn ->
        schema_url("etalab/schema-zfe", "foo")
      end
    end
  end

  defp assert_cache_key_has_ttl(cache_key, expected_ttl \\ 300) do
    assert_in_delta Cachex.ttl!(cache_name(), cache_key), :timer.seconds(expected_ttl), :timer.seconds(1)
  end

  defp setup_schema_response(expected_url) do
    Transport.HTTPoison.Mock
    |> expect(:get!, fn ^expected_url ->
      %HTTPoison.Response{body: ~s({"foo": "bar"}), status_code: 200}
    end)
  end

  defp setup_schemas_response do
    url = "https://schema.data.gouv.fr/schemas.json"

    Transport.HTTPoison.Mock
    |> expect(:get!, fn ^url ->
      %HTTPoison.Response{body: File.read!("#{__DIR__}/fixtures/schemas.json"), status_code: 200}
    end)
  end
end
