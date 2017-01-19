(** OCaml bindings to native Objective-C handling of plists *)

type plist

(** Create a plist from a JSON formatted string, raises
    Invalid_argument if input string isn't in a Plist readable
    format *)
external from_string : string -> plist = "plist_ml_from_string"

(** Convert a Plist into a pretty formated JSON string, raises
    Invalid_argument when plist can't be turned into a string *)
external to_string : plist -> string = "plist_ml_to_string"

(** Writing a plist to file, second argument is whether to write as
    binary; raises Invalid_argument if trying to convert plist to
    binary fails *)
external to_file : string -> bool -> plist -> unit = "plist_ml_to_file"

(** Raises Invalid_argument if file does not exist *)
external from_file : string -> plist = "plist_ml_from_file"

(** Returns the plist as raw binary bytes, raises Invalid_argument if
    plist can't be turned into raw bytes *)
external to_bytes : plist -> bytes = "plist_ml_to_bytes"

(** Simple helpers *)
let from_yojson s = from_string (Yojson.Basic.to_string s)
let to_yojson p = to_string p |> (Yojson.Basic.from_string)
