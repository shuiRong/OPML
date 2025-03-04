defmodule Opml.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Opml.Finch}
    ]

    opts = [strategy: :one_for_one, name: Opml.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
