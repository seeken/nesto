defmodule Nesto.Helpers do

  import Ecto.Changeset


  @container_class "mb-6"
  @label_class "mb-2 font-medium text-sm block text-gray-900 dark:text-gray-200"
  @input_class "border-gray-300 focus:border-primary-500 focus:ring-primary-500 dark:border-gray-600 dark:focus:border-primary-500 sm:text-sm block disabled:bg-gray-100 disabled:cursor-not-allowed shadow-sm w-full rounded-md dark:bg-gray-800 dark:text-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
  @select_class "border-gray-300 focus:border-primary-500 focus:ring-primary-500 dark:border-gray-600 dark:focus:border-primary-500
  block w-full disabled:bg-gray-100 disabled:cursor-not-allowed pl-3 pr-10 py-2 text-base focus:outline-none sm:text-sm
  rounded-md dark:disabled:bg-gray-700 dark:text-gray-300 dark:bg-gray-800 phx-no-feedback"

  def container_class do
    @container_class
  end

  def input_class do
    @input_class
  end

  def label_class do
    @label_class
  end

  def select_class do
    @select_class
  end





  def change_or_data(form, assoc_atom, fk_atom, opt_id, data_atom) do
    # IO.inspect(form.source.data, label: "Source")
    # IO.inspect(assoc_atom)
    # IO.inspect(fk_atom)
    # IO.inspect(opt_id)
    # IO.inspect(data_atom)


    ## TODO change to return errros

    try do
      match =
        get_field(form.source, assoc_atom)
        #  |> IO.inspect(label: "field #{fk_atom}")
        |> Enum.find(fn i -> Map.get(i, fk_atom) == opt_id end)

        #|> IO.inspect(label: "match")
      {Map.get(match, data_atom), match}
    rescue
      _err ->
        # IO.inspect(err)
        {"", nil}
    end
  end

  def gen_name(form, path) do
    ([form.name] ++ Enum.map(path, fn i -> "[#{to_string(i)}]" end))
    |> Enum.join("")
  end

  def gen_id(form, path) do
    ([form.id] ++ Enum.map(path, &to_string(&1)))
    |> Enum.join("_")
  end

end
