defmodule TransportWeb.Backoffice.BackofficePageController do
  use TransportWeb, :controller

  alias Transport.{Dataset, Region, Repo}
  import Ecto.Query
  require Logger

  @dataset_types [
    {dgettext("backoffice", "public-transit"), "public-transit"},
    {dgettext("backoffice", "carsharing-areas"), "carsharing-areas"},
    {dgettext("backoffice", "stops-ref"), "stops-ref"},
    {dgettext("backoffice", "charging-stations"), "charging-stations"},
    {dgettext("backoffice", "micro-mobility"), "micro-mobility"}
  ]

  ## Controller functions

  def index(%Plug.Conn{} = conn, %{"q" => q} = params) when q != "" do
    config = make_pagination_config(params)
    datasets =
      q
      |> Dataset.search_datasets
      |> preload([:region, :aom, :resources])
      |> Repo.paginate(page: config.page_number)

    conn
    |> assign(:regions, region_names())
    |> assign(:datasets, datasets)
    |> assign(:q, q)
    |> assign(:dataset_types, @dataset_types)
    |> render("index.html")
  end

  def index(%Plug.Conn{} = conn, params) do
    config = make_pagination_config(params)
    datasets =
      Dataset
      |> preload([:region, :aom, :resources])
      |> Repo.paginate(page: config.page_number)

    conn
    |> assign(:regions, region_names())
    |> assign(:datasets, datasets)
    |> assign(:dataset_types, @dataset_types)
    |> render("index.html")
  end

  ## Private functions
  defp region_names do
    Region
    |> Repo.all()
    |> Enum.map(fn r -> {r.nom, r.id} end)
    |> Enum.concat([{"Pas de region", nil}])
  end
end
