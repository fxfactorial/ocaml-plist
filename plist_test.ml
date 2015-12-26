(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

module Xml1 = struct

  let rt_string name s =
    let v = Plist.(Dict [name,String s]) in
    let xml_s = Plist.make v in
    let json = Plist.parse_dict xml_s in
    let json_s = Yojson.Basic.to_string json in
    Alcotest.(check string (name^" pnode -> json")
                ("{\""^name^"\":\""^s^"\"}") json_s);
    match Plutil.lint xml_s with
    | Result.Ok () -> ()
    | Result.Error errs -> Alcotest.fail (String.concat "\n" errs)

  let rt_ampersand ()   = rt_string "ampersand" "&"
  let rt_lessthan ()    = rt_string "lessthan" "<"
  let rt_tag ()         = rt_string "tag" "<script>alert(1);</script>"
  let rt_entity ()      = rt_string "amp" "&amp;"
  let rt_comment ()     = rt_string "comment" "<!-- -->"
  let rt_bad_comment () = rt_string "bad_comment" "<!--"

  let tests = [
    "rt_ampersand",   `Quick, rt_ampersand;
    "rt_lessthan",    `Quick, rt_lessthan;
    "rt_tag",         `Quick, rt_tag;
    "rt_entity",      `Quick, rt_entity;
    "rt_comment",     `Quick, rt_comment;
    "rt_bad_comment", `Quick, rt_bad_comment;
  ]
end

let tests = [
  "xml1", Xml1.tests;
]

;;
Alcotest.run "plist" tests
