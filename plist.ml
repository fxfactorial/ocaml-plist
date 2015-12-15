type pnode = Array of pnode list
           | Dict of (string * pnode) list
           | Integer of int
           | String of string
           | Key of string

let make value =
  let rec to_string e i_count = match e with
    | Integer i ->
      Printf.sprintf "\n%s<integer>%d</integer>" (String.make (i_count * 2) ' ') i
    | String s ->
      Printf.sprintf "\n%s<string>%s</string>" (String.make (i_count * 2) ' ') s
    | Key s ->
      Printf.sprintf "\n%s<key>%s</key>" (String.make (i_count * 2) ' ') s
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
  let rec do_parse_node node =
    match name node with
    | "string" ->
      String (match leaf_text node with Some s -> s | _ -> assert false)
    | "integer" ->
      Integer (match leaf_text node with Some i -> int_of_string i | _ -> assert false)
    | "key" -> Key (match leaf_text node with Some s -> s | _ -> assert false)
    | "dict" ->
      Array (List.map do_parse_node (children node |> elements |> to_list))
    | _ -> assert false
  in
  let first_dict = parse str $ "dict" |> children |> elements |> to_list in
  let pulled = List.map do_parse_node first_dict in
  let helper_stack = Stack.create () in
  let rec go_through l accum = match l with
    | Key k :: rest -> Stack.push k helper_stack; go_through rest accum
    | (String _) as str :: rest -> go_through rest ((Stack.pop helper_stack, str) :: accum)
    | (Integer _) as j :: rest -> go_through rest ((Stack.pop helper_stack, j) :: accum)
    | (Dict l) :: rest -> go_through (List.map snd l) accum
    | Array l :: rest -> go_through l accum
    | [] -> accum
  in
  go_through pulled [] |> List.rev
