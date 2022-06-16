defmodule DB.ResourceHistory do
  @moduledoc """
  ResourceHistory stores metadata when resources are historicized.
  """
  use Ecto.Schema
  use TypedEctoSchema
  import Ecto.Query

  @derive {Jason.Encoder, only: [:resource_id, :payload, :last_up_to_date_at, :inserted_at, :updated_at]}
  typed_schema "resource_history" do
    field(:datagouv_id, :string)
    field(:payload, :map)
    # the last moment we checked and the resource history was corresponding to the real online resource
    field(:last_up_to_date_at, :utc_datetime_usec)

    timestamps(type: :utc_datetime_usec)
    belongs_to(:resource, DB.Resource)
    has_many(:geo_data_import, DB.GeoDataImport)
    has_many(:validations, DB.MultiValidation)
  end

  defp latest_resource_history_query(resource_id) do
    DB.ResourceHistory
    |> where([rh], rh.resource_id == ^resource_id)
    |> order_by([rh], desc: rh.inserted_at)
    |> limit(1)
  end

  def latest_resource_history(%DB.Resource{id: id}), do: latest_resource_history(id)

  def latest_resource_history(resource_id) do
    resource_id
    |> latest_resource_history_query
    |> DB.Repo.one()
  end

  def latest_resource_history_payload(resource_id) do
    resource_id
    |> latest_resource_history_query
    |> select([rh], rh.payload)
    |> DB.Repo.one()
  end

  def latest_resource_history_infos(resource_id) do
    resource_id
    |> latest_resource_history_payload()
    |> case do
      %{"permanent_url" => url, "filesize" => filesize} -> %{url: url, filesize: filesize}
      _ -> nil
    end
  end

  @spec latest_dataset_resources_history_infos(integer()) :: map()
  def latest_dataset_resources_history_infos(dataset_id) do
    DB.Resource
    |> join(:left, [r], d in DB.Dataset, on: r.dataset_id == d.id, as: :d)
    |> join(:left, [r], rh in DB.ResourceHistory, on: rh.resource_id == r.id, as: :rh)
    |> where([r, d: d], d.id == ^dataset_id)
    |> order_by([rh: rh], desc: rh.inserted_at)
    |> distinct([r, rh: rh], rh.resource_id)
    |> select(
      [r, rh: rh],
      {r.id, %{url: fragment("payload->>'permanent_url'"), filesize: fragment("payload->>'filesize'")}}
    )
    |> DB.Repo.all()
    |> Enum.into(%{})
  end
end
