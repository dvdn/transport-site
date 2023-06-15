defmodule Datagouvfr.Client.User.Wrapper do
  @moduledoc """
  A wrapper for the User module, useful for testing purposes
  """
  @callback me(Plug.Conn.t()) :: {:error, map()} | {:ok, map()}

  def impl, do: Application.get_env(:datagouvfr, :user_impl)
end

defmodule Datagouvfr.Client.User.Dummy do
  @moduledoc """
  A dummy User, to avoid any communication with the Oauth Server.
  """
  @behaviour Datagouvfr.Client.User.Wrapper

  @impl Datagouvfr.Client.User.Wrapper
  def me(_),
    do:
      {:ok,
       %{
         "first_name" => "trotro",
         "last_name" => "rigolo",
         "id" => "user_id_1",
         "email" => "email@example.fr",
         "organizations" => [%{"slug" => "equipe-transport-data-gouv-fr", "name" => "PAN"}]
       }}
end

defmodule Datagouvfr.Client.User do
  @moduledoc """
  An Client to retrieve User information of data.gouv.fr
  """

  alias Datagouvfr.Client.OAuth, as: Client

  @me_fields ~w(avatar avatar_thumbnail first_name id last_name
                organizations page id uri apikey email)

  @doc """
  Call to GET /api/1/me/
  You can see documentation here: http://www.data.gouv.fr/fr/apidoc/#!/me/
  """
  @spec me(Plug.Conn.t(), [binary()]) :: {:error, OAuth2.Error.t()} | {:ok, OAuth2.Response.t()}
  def me(%Plug.Conn{} = conn, exclude_fields \\ []) do
    Client.get(conn, "me", [{"x-fields", xfields(exclude_fields)}])
  end

  # private functions

  @spec xfields([binary()]) :: binary()
  defp xfields(exclude_fields) do
    @me_fields
    |> Enum.filter(&(Enum.member?(exclude_fields, &1) == false))
    |> Enum.join(",")
  end
end
