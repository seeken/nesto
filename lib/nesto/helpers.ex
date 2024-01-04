defmodule Nesto.Helpers do

  import Ecto.Changeset


  @container_class "mb-6"
  @label_class "mb-2 font-medium text-sm block text-gray-900 dark:text-gray-200"
  @input_class "shadow appearance-none border border-black rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
  @select_class "border-gray-300 focus:border-black-500 focus:ring-black-500 dark:border-gray-600 dark:focus:border-black-500
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



  @doc """
    From an form, we try to fetch the existing data/or change from a changeset

  """


  def change_or_data(form, assoc_atom, fk_atom, opt_id, data_atom) do

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
