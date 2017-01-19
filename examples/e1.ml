let () =
  let f () =
    let json =
      (`Assoc [("hello", `List [`String "world"; `Int 10])])
    in
    let p = Plist.from_yojson json in
    Plist.to_file "test-idea.plist" true p;
    print_endline (Plist.to_string p)
  in
  f ();
  Gc.major ();
  print_endline "Finished GC Stress";
  let b () =
    let p = Plist.from_file "test-idea.plist" in
    let s = Plist.to_string p in
    print_endline s;
  in
  b ();

  let h () =
    let error = Plist.from_string "Hello world" in
    ()
  in
  (try h ();
   with Invalid_argument e -> print_endline e);
  let j () =
    let p =
      Plist.from_file "test-idea.plist"
      |> Plist.to_bytes
    in
    print_endline p
  in
  j ()
