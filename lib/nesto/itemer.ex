defmodule Nesto.Itemer do

  import Nesto.Helpers
  use Phoenix.Component

  #@form
  #@association
  #@association_ref_to_item
  #@items
  #@item_id_field
  #@item_name_field
  #@quantity

  def items(assigns) do
    ## form contains changeset which will have pre-ordered items.
    ## items is list of items in the order we want them
    ~H"""
    <%= for {item, index} <- Enum.with_index(@items) do %>
      <%= with {val, _rec} <- change_or_data(@form, @association, @association_ref_to_item, Map.get(item, @item_id_field), @quantity) do %>
        <div class={container_class()}>
          <input
            type="hidden"
            name={gen_name(@form, [@association, index, @association_ref_to_item])}
            value={Map.get(item, @item_id_field)}
            id={gen_id(@form, [@association, index, @association_ref_to_item])}
          />

          <label class={label_class()}>
            <!-- change to render a slot... -->
            <%= Map.get(item, @item_name_field) %>
            <input
              type="text"
              name={gen_name(@form, [@association, index, @quantity])}
              value={val}
              id={gen_id(@form, [@association, index, @quantity])}
              class={input_class()}
            />
          </label>
        </div>
      <% end %>
    <% end %>
    """
  end


end
