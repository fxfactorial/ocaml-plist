type node = Array of node list
          | Dict of (string * node) list
          | Int of int
          | String of string

let to_string value =
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
     DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\"/>"
  in
  Printf.sprintf "%s%s\n</plist>" boiler_plate (to_string value 1)
