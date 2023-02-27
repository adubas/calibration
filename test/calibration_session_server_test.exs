defmodule ElixirInterviewStarter.CalibrationSessionServerTest do
  use ExUnit.Case, async: true

  alias ElixirInterviewStarter.CalibrationSessionServer

  setup do
    email = "email@example.com"
    {:ok, pid} = CalibrationSessionServer.start_link(email)
    {:ok, pid: pid}
  end

  describe "precheck1/1" do
    test "success", %{pid: pid} do
      Process.send_after(pid, %{"precheck1" => true}, 100)

      assert {:ok, session} = CalibrationSessionServer.precheck1(pid)
      assert session.precheck1 == true
    end

    test "fails", %{pid: pid} do
      Process.send_after(pid, %{"precheck1" => false}, 100)

      assert {:error, "Failed to execute precheck 1"} = CalibrationSessionServer.precheck1(pid)
    end

    test "timeout", %{pid: pid} do
      Process.send_after(pid, %{"precheck1" => false}, 700)

      assert {:error, "Reached timeout"} = CalibrationSessionServer.precheck1(pid)
    end
  end

  describe "precheck2/1" do
    test "success", %{pid: pid} do
      create_with_precheck1(pid)
      Process.send_after(pid, %{"cartridgeStatus" => true, "submergedInWater" => true}, 200)

      assert {:ok, updated_session} = CalibrationSessionServer.precheck2(pid)
      assert updated_session.precheck1 == true
      assert updated_session.cartridge_status == true
      assert updated_session.submerged_in_water == true
    end

    test "fails", %{pid: pid} do
      create_with_precheck1(pid)
      Process.send_after(pid, %{"cartridgeStatus" => false, "submergedInWater" => false}, 100)

      assert {:error, "Failed to execute precheck 2"} = CalibrationSessionServer.precheck2(pid)
    end

    test "timeout", %{pid: pid} do
      create_with_precheck1(pid)
      Process.send_after(pid, %{"cartridgeStatus" => false, "submergedInWater" => false}, 600)

      assert {:error, "Reached timeout"} = CalibrationSessionServer.precheck2(pid)
    end

    test "fails when precheck1 has failed", %{pid: pid} do
      create_with_precheck1(pid, false)
      Process.send_after(pid, %{"cartridgeStatus" => true, "submergedInWater" => true}, 200)

      assert {:error, "Invalid session precheck does no meet criteria"} =
               CalibrationSessionServer.precheck2(pid)
    end

    test "fails when precheck 1 was not executed", %{pid: pid} do
      Process.send_after(pid, %{"cartridgeStatus" => true, "submergedInWater" => true}, 200)

      assert {:error, "Invalid session precheck does no meet criteria"} =
               CalibrationSessionServer.precheck2(pid)
    end

    test "execute calibration after success", %{pid: pid} do
      create_with_precheck2(pid)
      Process.send_after(pid, %{"calibrated" => true}, 200)

      assert updated_session = CalibrationSessionServer.fetch_session(pid)
      assert updated_session.calibrated == true
    end

    test "handle calibration timeout after success", %{pid: pid} do
      create_with_precheck2(pid)
      Process.send_after(pid, %{"calibrated" => true}, 600)

      assert updated_session = CalibrationSessionServer.fetch_session(pid)
      assert updated_session.calibrated == false
    end
  end

  defp create_with_precheck2(pid, result \\ true) do
    create_with_precheck1(pid)
    Process.send_after(pid, %{"cartridgeStatus" => result, "submergedInWater" => result}, 100)
    CalibrationSessionServer.precheck2(pid)
  end

  defp create_with_precheck1(pid, result \\ true) do
    Process.send_after(pid, %{"precheck1" => result}, 50)
    CalibrationSessionServer.precheck1(pid)
  end
end
