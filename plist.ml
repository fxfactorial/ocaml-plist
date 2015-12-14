type node = Array of node list
          | Dict of (string * node) list
          | Int of int
          | String of string

let make value =
  let rec to_string e i_count = match e with
    | Int i ->
      Printf.sprintf "\n%s<integer>%d</integer>" (String.make (i_count * 2) ' ') i
    | String s ->
      Printf.sprintf "\n%s<string>%s</string>" (String.make (i_count * 2) ' ') s
    | Array l ->
      Printf.sprintf "\n%s<array>%s\n%s</array>"
        (String.make (i_count * 2) ' ')
        (l |> List.map begin fun e_ ->
            to_string e_ (i_count * 2)
          end
         |> String.concat "")
        (String.make (i_count * 2) ' ')
    | Dict l ->
      Printf.sprintf "\n%s<dict>%s\n%s</dict>"
        (String.make (i_count * 2) ' ')
        (l |> List.map begin fun (k, e_) ->
            Printf.sprintf "\n%s<key>%s</key>%s"
              (String.make (i_count * 4) ' ')
              k
              (to_string e_ (i_count * 2))
          end
         |> String.concat "")
        (String.make (i_count * 2) ' ')
  in
  let boiler_plate =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist \
     PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/\
     DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">"
  in
  Printf.sprintf "%s%s\n</plist>" boiler_plate (to_string value 1)

let parse_dict str =
  let open Soup in
  let dict = parse str $ "dict" in
  let dict_keys = dict |> tags "key" |> fold begin fun accum a_key ->
      match leaf_text a_key with
      | None -> accum
      | Some a -> a :: accum
    end []
  in
  let dict_values = dict $$ ":not(key)" |> fold begin fun accum a_key ->
      match leaf_text a_key with
      | None -> accum
      | Some innard -> (name a_key, innard) :: accum
    end []
  in
  List.combine dict_keys dict_values
  |> List.map begin function
      (key, (typ, data)) -> match typ with
      | "string" -> (key, String data)
      | "integer" -> (key, Int (int_of_string data))
      | _ -> assert false
  end
  |> List.rev
