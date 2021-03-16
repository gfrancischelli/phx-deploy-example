defmodule ExampleWeb.SlowController do
  use ExampleWeb, :controller

  def index(conn, _params) do
    conn.query_params
    |> Map.get("t", "1000")
    |> String.to_integer()
    |> :timer.sleep()

    text(conn, "ok")
  end
end
