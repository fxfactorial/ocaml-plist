type plist

external from_string : string -> plist = "plist_ml_from_string"
external to_string : plist -> string = "plist_ml_to_string"

(** Writing a plist to file, second argument is whether to write as
    binary *)
external to_file : string -> bool -> plist -> unit = "plist_ml_to_file"

(** Raises Invalid_argument if file does not exist *)
external from_file : string -> plist = "plist_ml_from_file"

let from_yojson s = from_string (Yojson.Basic.to_string s)
let to_yojson p = to_string p |> (Yojson.Basic.from_string)
