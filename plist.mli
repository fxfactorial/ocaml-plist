type pnode =
    Array of pnode list
  | Dict of (string * pnode) list
  | Integer of int
  | String of string
  | Key of string

val make : pnode -> string

val parse_dict : string -> Yojson.Basic.json
