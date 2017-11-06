defmodule Legato.Response do

  import Access, only: [all: 0, key: 2]

  def build({:ok, %HTTPoison.Response{body: body, headers: _headers}}) do
    Poison.decode!(body) |> as_report
  end

  def build({:error, %HTTPoison.Error{}} = err), do: err

  defp as_report(%{"error" => errors}) do
    IO.inspect errors
  end

  defp as_report(%{"reports" => reports}) do
    rows = get_in(reports, [all(), key("data", %{}), key("rows", nil)])
    rows_exist? = Enum.all?(rows)
    case rows_exist? do
      false -> {:error, "rows are not present in the response"}
      true -> Legato.Report.from_json(reports)
    end
  end
end
