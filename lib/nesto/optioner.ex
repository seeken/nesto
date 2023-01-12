defmodule Nesto.Optioner do
  import Nesto.Helpers

  use Phoenix.Component

  ### the form we wish we could just use...
  attr :form, :any, required: true
  ### the Questions asked, having id and name, AND member refered to below in :option_avail_list
  attr :options, :list, required: true

  ### The form represents parent schema, this contains the 'association' name that will hold children
  attr :assoc_name, :atom, required: true

  ### for parent -> X -> option_choice relation, this lives in X and refers to the option owning option_choice
  attr :assoc_option_key, :atom, required: true
  ### in X, this points to the option_choice_id
  attr :assoc_selection_key, :atom, required: true
  ### In options, the choices
  attr :option_avail_list, :atom, required: true

  def optioner(assigns) do
    ~H"""
    <%= for {option, index} <- Enum.with_index(@options) do %>
      <%= with { selected_val, _record } <- change_or_data(@form, @assoc_name, @assoc_option_key, option.id, @assoc_selection_key) do %>
        <div class={container_class()}>
          <input
            type="hidden"
            name={gen_name(@form, [@assoc_name, index, @assoc_option_key])}
            value={option.id}
            id={gen_id(@form, [@assoc_name, index, @assoc_option_key])}
          />

          <label class={label_class()}>
            <%= option.name %>
            <select
              name={gen_name(@form, [@assoc_name, index, @assoc_selection_key])}
              id={gen_id(@form, [@assoc_name, index, @assoc_selection_key])}
              class={select_class()}
            >
              <%= for choice <- Map.get( option, @option_avail_list) do %>
                <option value={choice.id} selected={choice.id == selected_val}>
                  <%= choice.name %>
                </option>
              <% end %>
            </select>
          </label>
        </div>
      <% end %>
    <% end %>
    """
  end

end
