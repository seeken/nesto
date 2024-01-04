Application.put_env(:sample, Nesto.Run.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5001],
  server: true,
  live_view: [signing_salt: "aaaaaaaa"],
  secret_key_base: String.duplicate("a", 64)
)

Mix.install([
  {:plug_cowboy, "~> 2.5"},
  {:jason, "~> 1.0"},
  {:phoenix, "~> 1.7.0"},
  {:phoenix_html, "~> 3.0"},
  {:phoenix_live_view, "~> 0.20.3"},
  {:ecto, "~> 3.11.1"},
  {:ecto_nested_changeset, "~> 0.2.0"},
  {:nesto, path: "../nesto"}
])

defmodule Nesto.ErrorView do
  def render(template, a) do
    IO.inspect(a)
   Phoenix.Controller.status_message_from_template(template)
  end

end

defmodule Nesto.Run.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :delete, :boolean, virtual: true
    has_many :questions, Nesto.Run.Question
    has_many :options, Nesto.Run.Option
    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :delete])
    |> cast_assoc(:questions, required: false)
    |> cast_assoc(:options, required: false)
    |> Nesto.NestedSubform.maybe_mark_for_deletion()
  end
end
defmodule Nesto.Run.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :name, :string
    belongs_to :event, Nesto.Run.Event
    field :delete, :boolean, virtual: true
    has_many :option_choices, Nesto.Run.OptionChoice
    timestamps()
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:name, :delete])
    |> Nesto.NestedSubform.maybe_mark_for_deletion()
  end
end

defmodule Nesto.Run.OptionChoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "option_choices" do
    field :name, :string
    field :delete, :boolean, virtual: true
    belongs_to :option, Nesto.Run.Option
    timestamps()
  end

  def changeset(option_choice, attrs) do
    option_choice
    |> Map.put(:temp_id, option_choice.temp_id || attrs["temp_id"])
    |> cast(attrs, [:name, :delete])
    |> Nesto.NestedSubform.maybe_mark_for_deletion()
  end
end

defmodule Nesto.Run.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :name, :string
    field :delete, :boolean, virtual: true
    has_many :options, Nesto.Run.Option
    timestamps()
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:name, :delete])
    |> cast_assoc(:options, required: false)
    |> Nesto.NestedSubform.maybe_mark_for_deletion()
  end
end



defmodule Nesto.Run.HomeLive do
  use Phoenix.LiveView, layout: {__MODULE__, :live}
  use Nesto.NestedSubform
  use Phoenix.HTML
  use Phoenix.Component
  def mount(_params, _session, socket) do
    {:ok, assign(socket, changeset: Nesto.Run.Event.changeset(%Nesto.Run.Event{}, %{}))}
  end

  defp phx_vsn, do: Application.spec(:phoenix, :vsn)
  defp lv_vsn, do: Application.spec(:phoenix_live_view, :vsn)

  def render("live.html", assigns) do
    ~H"""
    <script src={"https://cdn.jsdelivr.net/npm/phoenix@#{phx_vsn()}/priv/static/phoenix.min.js"}></script>
    <script src={"https://cdn.jsdelivr.net/npm/phoenix_live_view@#{lv_vsn()}/priv/static/phoenix_live_view.min.js"}></script>
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
      liveSocket.connect()
    </script>
    <style>
      * { font-size: 1.1em; }
    </style>
    <%= @inner_content %>
    """
  end

  def render(assigns) do
    ~H"""
    <div>HI
    <.form :let={form} for={@changeset} phx-change="validate" phx-submit="save">

      <.nesto_subform title="Name of this subform for header" form={form} type={:questions} >
          <:cell :let={sub_form}>
            ### Your first field
          </:cell>
          <:cell :let={sub_form}>
            ### Your second field, etc
          </:cell>
          <:del_existing :let={sub_form}>
            <%= hidden_input sub_form, :id %>
            <checkbox id={"your_assoc_name_\#{sub_form.data.id}"} form={sub_form} field={:delete} label="Delete"/>
          </:del_existing>
        </.nesto_subform>

      </.form>
      </div>
    """
  end



end

defmodule Nesto.Run.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", Nesto.Run do
    pipe_through(:browser)

    live("/", HomeLive, :index)
  end
end

defmodule Nesto.Run.Endpoint do
  use Phoenix.Endpoint, otp_app: :sample
  socket("/live", Phoenix.LiveView.Socket)
  plug(Nesto.Run.Router)
end

{:ok, _} = Supervisor.start_link([Nesto.Run.Endpoint], strategy: :one_for_one)
Process.sleep(:infinity)
