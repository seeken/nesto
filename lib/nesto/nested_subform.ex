defmodule Nesto.NestedSubform do

  use Phoenix.HTML
  use Phoenix.Component
  use PetalComponents

  @moduledoc """
    Adapted from https://fullstackphoenix.com/tutorials/nested-model-forms-with-phoenix-liveview

    Can create up to 2 level deep nested forms.


  """


  def dep_subform(assigns) do
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
