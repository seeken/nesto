defmodule Nesto.NestedSubform do

  use Phoenix.HTML
  use Phoenix.Component
  use PetalComponents
  import Ecto.Changeset

  @moduledoc """
    Adapted from https://fullstackphoenix.com/tutorials/nested-model-forms-with-phoenix-liveview

    This module is self contained. If you want to style it, you copy this to your project and change it there. Note you have to update the 'import Nesto.NestedSubform' in the __using__

    Can create up to 2 level deep nested forms.

    When using this form, you must:

    Most important, have your schema assocs setup correctly, with main schema has_many and the associated schema belongs_to.


    Items to look for to replace below:
    - :your_assoc_schema


    IN YOUR SUB SCHEMA:
    ===============

    add temp_id and delete virtual fields to the assoc's schema and changeset, and pass changeset through
    the maybe_mark_for_deletion.

    ```elixir
      # In schema:
      field :temp_id, :string, virtual: true
      field :delete, :boolean, virtual: true

      #Example Changeset

      def changeset(example, attrs) do
        example
        |> Map.put(:temp_id, example.temp_id || attrs["temp_id"])
        |> cast(attrs, [:your, :other, :fields , :delete])
        |> Nesto.NestedSubform.maybe_mark_for_deletion()
      end
    ```

    IN YOUR CONTEXT
    ===============

    The containing struct should have the Available Items preloaded, in order.

    ```elixir
      Repo.get!(YourMainSchema, id)
      |> Repo.preload(items: from(i in YourApp.YourContext.YourAssocSchema, order_by: i.display_order))
    ```

    IN YOUR MAIN SCHEMA
    ===================

    You need to add your sub schema in cast_assoc in the changeset function you're going to use

    ```elixir
      def changeset(example, attrs) do
        example
        |> cast(attrs, [:your, :fields])
        |> cast_assoc( :your_assoc_schema )
      end
    ```

    IN YOUR LIVEVIEW
    ================

    You must 'use Nesto.NestedSubform' to bring in the event handlers. Note the del_existing. This contains a checkbox that has to have a unique ID, otherwise liveview will cut corners and leave it checked!

    ```elixir
      <.nesto_subform title="Name of this subform for header" form={form} type={:your_assoc_schema} >
        <:cell :let={sub_form}>
          ### Your first field
        </:cell>
        <:cell :let={sub_form}>
          ### Your second field, etc
        </:cell>
        <:del_existing :let={sub_form}>
          <%= hidden_input sub_form, :id %>
          <.checkbox id={"your_assoc_name_#{sub_form.data.id}"} form={sub_form} field={:delete} label="Delete"/>
        </:del_existing>
      </.nesto_subform>
    ```

    You must add add_blank_dep functions for each assoc type, these will be called by the handlers

  ```elixir
    def add_blank_dep(:your_assoc_schema) do
      YourApp.YourContext.create_changeset_for_your_assoc_schema(
        # NOTE temp_id
        %YourApp.YourContext.YourAssocSchema{temp_id: get_temp_id()}
      )
    end
  ```

    You can have sub-sub-forms, too. You need to make the preloads and changesets to include the sub-assocs.
=

    ```elixir
      <.nesto_subform title="Name of subform" form={form} type={:your_assoc_schema} >
        <:cell :let={sub_form}>
          ### Field
        </:cell>
        <:del_existing :let={sub_form}>
          <%= hidden_input sub_form, :id %>
          <.checkbox id={"your_assoc_schema#{sub_form.data.id}"} form={sub_form} field={:delete} label="Delete"/>
        </:del_existing>
        <:subsection :let={sub_form}>
          <.nesto_subform title="Name of sub-sub-form" form={sub_form} type={:sub_sub_assoc_name} parent={:your_assoc_schema} index={sub_form.index} >
            <:cell :let={sub_sub_form}>
              Field ...
            </:cell>
            <:del_existing :let={sub_sub_form}>
              <%= hidden_input sub_sub_form, :id %>
              <.checkbox id={"sub_sub_assoc_name#{sub_sub_form.data.id}"} form={sub_sub_form} field={:delete} label="Delete"/>
            </:del_existing>
          </.nesto_subform>
        </:subsection>
      </.nesto_subform>
    ```

  """


  def nesto_subform(assigns) do
    ~H"""
    <.card>
      <.card_content heading={if assigns[:title] do @title else nil end}>
        <table>
          <%= for sub_form <- inputs_for( @form, @type ) do %>
            <tr>
              <td :for={cell <- @cell}>
                <%= render_slot(cell, sub_form) %>
              </td>
              <td>
                <%= label(sub_form, "delete") %><br />
                <%= if is_nil(sub_form.data.temp_id) do %>
                  <%= render_slot(@del_existing, sub_form) %>
                <% else %>
                  <%= hidden_input(sub_form, :temp_id) %>
                  <.remove_button type={@type} remove={if assigns[:parent] do sub_form.index else sub_form.data.temp_id end }
                    parent={assigns[:parent]} index={assigns[:index]}/>
                <% end %>
              </td>
            </tr>
            <tr :if={assigns[:subsection]}>
              <td class="pl-24" colspan={Enum.count(@cell)}>
                <%= render_slot(@subsection, sub_form) %>
              </td>
            </tr>
          <% end %>

        </table>
        <.add_button type={@type} parent={assigns[:parent]} index={assigns[:index]}/> Add
      </.card_content>
    </.card>
    """
  end

  defp add_button(assigns) do
    ~H"""
    <Heroicons.plus solid class="w-6 h-6 text-red-800 inline border border-2 border-red-800 rounded-md"
      color="primary"
      phx-click="add_dep"
      phx-value-type={@type}
      phx-value-parent-type={@parent}
      phx-value-index={@index}
    />
    """
  end

  defp remove_button(assigns) do
    ~H"""
    <Heroicons.x_mark solid class="w-6 h-6 text-red-800 inline border border-2 border-red-800 rounded-md"
      type="button"
      color="secondary"
      href="#"
      phx-click="remove_dep"
      phx-value-parent-type={@parent}
      phx-value-type={@type}
      phx-value-index={@index}
      phx-value-remove={@remove}
    />

    """
  end

  def maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  def maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end


  defmacro __using__(_) do
    quote do
      import Nesto.NestedSubform
      import EctoNestedChangeset

      defp add_dep(changeset, path, dep) do
        changeset
        |> append_at(path, dep)
      end

      defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

      defp remove_temp_item(list, remove_id) do
        list
        |> Enum.reject(fn %{data: dep} ->
          dep.temp_id == remove_id
        end)
      end

      def handle_event(
            "add_dep",
            %{"type" => dep_type, "index" => index, "parent-type" => parent_type} = _params,
            socket
          ) do
        dep_atom = String.to_atom(dep_type)
        parent_type_atom = String.to_atom(parent_type)
        index = String.to_integer(index)

        changeset =
          socket.assigns.changeset
          |> add_dep([parent_type_atom, index, dep_atom], add_blank_dep(dep_atom))

        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("add_dep", %{"type" => dep_type} = _params, socket) do
        dep_atom = String.to_atom(dep_type)

        changeset =
          socket.assigns.changeset
          |> add_dep([dep_atom], add_blank_dep(dep_atom))

        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event(
            "remove_dep",
            %{
              "type" => dep_type,
              "index" => index,
              "remove" => remove_index,
              "parent-type" => parent_type
            },
            socket
          ) do
        dep_atom = String.to_atom(dep_type)
        parent_type_atom = String.to_atom(parent_type)
        index = String.to_integer(index)
        remove_index = String.to_integer(remove_index)

        changeset =
          socket.assigns.changeset
          |> delete_at([parent_type_atom, index, dep_atom, remove_index])

        {:noreply, assign(socket, changeset: changeset)}
      end

      def handle_event("remove_dep", %{"type" => dep_type, "remove" => remove_id}, socket) do
        dep_atom = String.to_atom(dep_type)

        replacement_deps =
          Map.get(socket.assigns.changeset.changes, dep_atom)
          |> remove_temp_item(remove_id)

        changeset =
          socket.assigns.changeset
          |> Ecto.Changeset.put_assoc(dep_atom, replacement_deps)

        {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end
end
