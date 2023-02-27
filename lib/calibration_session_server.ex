defmodule ElixirInterviewStarter.CalibrationSessionServer do
  @moduledoc """
  A server to manage the calibration sessions states
  """
  use GenServer

  alias ElixirInterviewStarter.{CalibrationSession, DeviceMessages}

  @precheck1_timeout Application.compile_env(:elixir_interview_starter, [:timeouts, :precheck1])
  @precheck2_timeout Application.compile_env(:elixir_interview_starter, [:timeouts, :precheck2])
  @calibrate_timeout Application.compile_env(:elixir_interview_starter, [:timeouts, :calibrate])

  def start_link(email) do
    GenServer.start_link(__MODULE__, email)
  end

  @impl true
  def init(email) do
    session = %CalibrationSession{email: email}
    {:ok, session}
  end

  def fetch_session(pid) do
    GenServer.call(pid, :session)
  end

  def precheck1(pid) do
    GenServer.call(pid, :precheck1, :infinity)
  end

  def precheck2(pid) do
    GenServer.call(pid, :precheck2, :infinity)
  end

  @impl true
  def handle_call(:session, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:precheck1, _from, state) do
    DeviceMessages.send(state.email, "startPrecheck1")

    receive do
      %{"precheck1" => true} ->
        new_state = %{state | precheck1: true}
        {:reply, {:ok, new_state}, new_state}

      %{"precheck1" => false} ->
        new_state = %{state | precheck1: false}
        {:reply, {:error, "Failed to execute precheck 1"}, new_state}
    after
      @precheck1_timeout ->
        new_state = %{state | precheck1: false}
        {:reply, {:error, "Reached timeout"}, new_state}
    end
  end

  @impl true
  def handle_call(:precheck2, _from, state) do
    case is_session_valid?(state) do
      true ->
        DeviceMessages.send(state.email, "startPrecheck2")

        receive do
          result ->
            result
            |> update_session_after_precheck2(state)
            |> verify_precheck2_result()
            |> case do
              {:ok, new_state} = result ->
                {:reply, result, new_state, {:continue, :calibrate}}

              {:error, new_state} ->
                {:reply, {:error, "Failed to execute precheck 2"}, new_state}
            end
        after
          @precheck2_timeout ->
            new_state = %{state | cartridge_status: false, submerged_in_water: false}
            {:reply, {:error, "Reached timeout"}, new_state}
        end

      false ->
        {:reply, {:error, "Invalid session precheck does no meet criteria"}, state}
    end
  end

  @impl true
  def handle_continue(:calibrate, state) do
    DeviceMessages.send(state.email, "calibrate")

    receive do
      %{"calibrated" => result} ->
        new_state = %{state | calibrated: result}
        {:noreply, new_state}
    after
      @calibrate_timeout ->
        new_state = %{state | calibrated: false}
        {:noreply, new_state}
    end
  end

  defp is_session_valid?(%CalibrationSession{precheck1: true}), do: true
  defp is_session_valid?(_state), do: false

  defp update_session_after_precheck2(result, state) do
    state
    |> Map.put(:cartridge_status, Map.get(result, "cartridgeStatus"))
    |> Map.put(:submerged_in_water, Map.get(result, "submergedInWater"))
  end

  defp verify_precheck2_result(
         %CalibrationSession{cartridge_status: true, submerged_in_water: true} = state
       ),
       do: {:ok, state}

  defp verify_precheck2_result(state), do: {:error, state}
end
