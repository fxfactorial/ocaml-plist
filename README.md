


Simple way to create Apple plists.

```shell
$ opam install plist
```

```ocaml

open Plist

let () = 
  print_endline (to_string (Array [Dict [("Hey", (String "Arnold"))]]))
```

Plist can also parse simple plists and will flatten dictionaries.