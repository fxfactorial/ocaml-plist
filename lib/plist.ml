type plist

external from_string : string -> plist = "plist_ml_from_string"
external to_string : plist -> string = "plist_ml_to_string"

external to_file : string -> plist -> unit = "plist_ml_to_file"

(* external from_file : string -> plist_ptr = "plist_ml_from_file" *)
(* external get : plist_ptr -> string -> plist_ptr = "plist_ml_get" *)

let from_yojson s = from_string (Yojson.Basic.to_string s)
let to_yojson p = to_string p |> (Yojson.Basic.from_string)
