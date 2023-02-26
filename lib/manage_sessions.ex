defmodule ElixirInterviewStater.ManageSessions do
  @moduledoc """
  A sever to manage sessions
  """

  use GenServer

  alias ElixirInterviewStarter.CalibrationSessionServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def create_session_server(email) do
    GenServer.call(__MODULE__, {:start_session_server, email}, :infinity)
  end

  def execute_precheck2(email) do
    GenServer.call(__MODULE__, {:execute_precheck2, email}, :infinity)
  end

  def fetch_session(email) do
    GenServer.call(__MODULE__, {:fetch_session, email})
  end

  @impl true
  def handle_call({:start_session_server, email}, _from, state) do
    if Map.has_key?(state, email) do
      {:reply, {:error, "Session already exists"}, state}
    else
      case CalibrationSessionServer.start_link(email) do
        {:ok, pid} ->
          session = CalibrationSessionServer.fetch_session(pid)
          new_state = Map.put(state, email, pid)
          {:reply, {:ok, session}, new_state}

        _error ->
          {:reply, {:error, "Start calibration session failed"}, state}
      end
    end
  end

  @impl true
  def handle_call({:execute_precheck2, email}, _from, state) do
    if Map.has_key?(state, email) do
      pid = Map.get(state, email)
      result = CalibrationSessionServer.precheck2(pid)
      {:reply, result, state}
    else
      {:reply, {:error, "There is no calibration session for #{email}"}, state}
    end
  end

  @impl true
  def handle_call({:fetch_session, email}, _from, state) do
    if Map.has_key?(state, email) do
      pid = Map.get(state, email)
      result = CalibrationSessionServer.fetch_session(pid)
      {:reply, result, state}
    else
      {:reply, {:error, "There is no calibration session for #{email}"}, state}
    end
  end
end
