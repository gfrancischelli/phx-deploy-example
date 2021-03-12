defmodule Example do
  @moduledoc """
  Example keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def measure_users do
    :telemetry.execute([:example, :users], %{total: 10}, %{})
  end
end
