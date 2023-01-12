defmodule Nesto.Questioner do
  use Phoenix.HTML
  use Phoenix.Component
  use PetalComponents

  import Nesto.Helpers


  #@form
  #@association
  #@association_ref_to_question_id
  #@questions
  #@question_id_field
  #@question_question_field
  #@response

  def questioner(assigns) do
    ~H"""
    <%= for {question, index} <- Enum.with_index(@questions) do %>
      <%= with { val, _rec } <- change_or_data(@form, @association, @association_ref_to_question, Map.get(question, @question_id_field), @response ) do %>
        <div class={container_class()}>
          <input
            type="hidden"
            name={gen_name(@form, [@association, index, @association_ref_to_question])}
            value={question.id}
            id={gen_id(@form, [@association, index, @association_ref_to_question])}
          />
          <label class={label_class()}>
            <%= Map.get(question, @question_question_field) %>
            <input
              type="text"
              name={gen_name(@form, [@association, index, @response])}
              id={gen_id(@form, [@association, index, @response])}
              value={val}
              class={input_class()}
            />
          </label>
        </div>
      <% end %>
    <% end %>
    """
  end



end
