# mix run --no-start scripts/cleanup_data.exs [input youdao.dets]

Application.ensure_all_started(:jason)

require Logger

filepath = System.argv() |> Enum.at(0)

{:ok, _} =
  :dets.open_file(:input,
    access: :read,
    file: String.to_charlist(filepath)
  )

{:ok, _} =
  :dets.open_file(:output,
    access: :read_write,
    file: String.to_charlist(filepath <> ".out")
  )

{purged, count} =
  :dets.foldl(
    fn ({key, resp, count}, acc) ->
      {bks, count} = acc
      new_bks = case Jason.decode(resp) do
        {:ok, r} ->
          ec = Map.get(r, "errorCode", 0)

          if ec == 0 do
            :dets.insert(:output, {key, resp, count})
            bks
          else
            Logger.info("bad response #{Kernel.inspect(r)}")
            bks + 1
          end

        {:err, _} ->
          bks + 1
      end

      {new_bks, count + 1}
    end,
    {0, 0},
    :input
  )

Logger.info("total: #{count}, purged: #{purged}")

:ok = :dets.close(:input)
:ok = :dets.close(:output)
