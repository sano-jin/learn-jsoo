open Js_of_ocaml

let () =
  (* let elem = Dom_html.getElementById_exn "container" in *)
  (* let idstr = Js.to_string elem##.id in *)
  (* print_endline idstr; *)
  (* let div = Dom_html.createDiv Dom_html.window##.document in *)
  (* let jsstr = Js.string "hi from ocaml" in *)
  (* div##.get jsstr; *)
  (* let elem = Dom_html.createDiv jsstr in *)
  (* Dom.appendChild Dom_html.document##.body div; *)
  (* print_endline "hello from js" *)
  print_endline "hello from js";

  (* let document = Dom_html.document in *)
  (* match *)
  (*   Js.Opt.to_option (document##getElementById (Js.string "element-id")) *)
  (* with *)
  (* | Some element -> *)
  (*     let element = Js.Unsafe.coerce element in *)
  (*     element##.innerText := Js.string "新しいテキスト"; *)
  (*     Dom.appendChild Dom_html.document##.body element *)
  (* | None -> () *)
  let element = Dom_html.createDiv Dom_html.window##.document in
  let element = Js.Unsafe.coerce element in
  element##.innerText := Js.string "Newly added text.";
  Dom.appendChild Dom_html.document##.body element
