defmodule TransportWeb.SeoMetadataTest do
  @moduledoc """
  test seo metadata
  """
  use TransportWeb.ConnCase, async: false
  use TransportWeb.ExternalCase
  use TransportWeb.DatabaseCase, cleanup: [:datasets]
  alias DB.{AOM, Dataset, Repo, Resource, Validation}

  setup do
    {:ok, _} =
      %Dataset{
        description: "Un jeu de données",
        licence: "odc-odbl",
        title: "Horaires et arrêts du réseau IRIGO - format GTFS",
        spatial: "Horaires Angers",
        type: "public-transit",
        slug: "horaires-et-arrets-du-reseau-irigo-format-gtfs",
        datagouv_id: "5b4cd3a0b59508054dd496cd",
        frequency: "yearly",
        tags: [],
        resources: [
          %Resource{
            url: "https://link.to/angers.zip",
            validation: %Validation{
              details: %{},
              max_error: "Info"
            },
            description: "blabla on resource",
            format: "GTFS",
            metadata: %{"networks" => [], "modes" => []},
            title: "angers.zip",
            modes: ["ferry"],
            id: 1234
          }
        ],
        aom: %AOM{id: 4242, nom: "Angers Métropôle"}
      }
      |> Repo.insert()

    :ok
  end

  defp title(page) do
    ~r|.*<title>(.*)</title>.*|
    |> Regex.run(page)
    |> case do
      [_ | [title | _]] -> title
      # if not found return all
      _ -> page
    end
  end

  test "GET / ", %{conn: conn} do
    title = conn |> get("/") |> html_response(200) |> title
    assert title =~ "Le Point d’Accès National aux données ouvertes de transport"
  end

  test "GET /datasets ", %{conn: conn} do
    title = conn |> get(dataset_path(conn, :index)) |> html_response(200) |> title
    assert title =~ "Le Point d’Accès National aux données ouvertes de transport"
  end

  test "GET /datasets/aom/4242 ", %{conn: conn} do
    title = conn |> get("/datasets/aom/4242") |> html_response(200) |> title
    assert title =~ "Jeux de données ouverts de l&#39;AOM Angers Métropôle"
  end

  test "GET /datasets/region/12 ", %{conn: conn} do
    region = Repo.get_by(Region, nom: "Pays de la Loire")
    title = conn |> get("/datasets/region/#{region.id}") |> html_response(200) |> title
    assert title =~ "Jeux de données ouverts de la région Pays de la Loire"
  end

  test "GET /datasets/commune/36044 ", %{conn: conn} do
    title = conn |> get("/datasets/commune/36044") |> html_response(200) |> title
    assert title =~ "Jeux de données ouverts de la commune de Châteauroux"
  end

  test "GET /datasets?type=bike-sharing ", %{conn: conn} do
    title = conn |> get("/datasets?type=bike-sharing") |> html_response(200) |> title
    assert title =~ "Jeux de données ouverts de la catégorie Vélo partage"
  end

  test "GET /dataset/:id ", %{conn: conn} do
    title = conn |> get("/datasets/horaires-et-arrets-du-reseau-irigo-format-gtfs") |> html_response(200) |> title
    assert title =~ "Jeux de données ouverts de Horaires Angers - Angers Métropôle (GTFS)"
  end

  test "GET /resources/:id ", %{conn: conn} do
    title = conn |> get("/resources/1234") |> html_response(200) |> title
    assert title =~ "Jeu de données ouvert GTFS - angers.zip pour Horaires Angers - Angers Métropôle"
  end

  test "GET /real_time ", %{conn: conn} do
    title = conn |> get("/real_time") |> html_response(200) |> title
    assert title =~ "Liste des données temps-réel de transport en commun, non standardisées"
  end

  test "GET /aoms ", %{conn: conn} do
    title = conn |> get("/aoms") |> html_response(200) |> title
    assert title =~ "État de l’ouverture des données de transport en commun pour les AOMs françaises"
  end

  test "GET /validation ", %{conn: conn} do
    title = conn |> get("/validation") |> html_response(200) |> title
    assert title =~ "Évaluation de la qualité d’un jeu de données GTFS"
  end
end
