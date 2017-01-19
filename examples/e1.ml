
let () =
  let f () =
    let json =
      (`Assoc [("hello", `List [`String "world"; `Int 10])])
    in
    let p = Plist.from_yojson json in
    Plist.to_file "test-idea.plist" p;
    print_endline (Plist.to_string p)
  in
  f ();
  Gc.major ();
  print_endline "Finsihed";

  let b () =
    let p = Plist.from_file "test-idea.plist" in
    ()
  in
  b ()
