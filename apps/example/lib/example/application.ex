defmodule Example.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Example.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Example.PubSub},
      # Start a worker by calling: Example.Worker.start_link(arg)
      # {Example.Worker, arg}
      {Example.MyServer, fn -> "Hello, world!" end}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Example.Supervisor)
  end
end
