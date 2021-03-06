defmodule GBFS.ErrorView do
  use GBFS, :view
  alias Phoenix.Controller

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Controller.status_message_from_template(template)}}
  end

  def render("error.json", %{error: error}) do
    Sentry.capture_message("GBFS error",
      level: "error",
      extra: %{details: error}
    )

    %{error: error}
  end
end
