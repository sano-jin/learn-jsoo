open Js_of_ocaml

let onload _ =
  let elem = Dom_html.getElementById_exn "hello-elem-id" in
  let str = Js.to_string elem##.innerText in
  print_endline str;

  let document = Dom_html.window##.document in
  let element = Dom_html.createDiv document in
  element##.innerText := Js.string "Newly added text.";
  Dom.appendChild Dom_html.document##.body element;

  let button =
    Dom_html.createButton ~_type:(Js.string "button") ~name:(Js.string "button")
      Dom_html.window##.document
  in

  button##.innerText := Js.string "This is a button.";

  (* クリックイベントハンドラを設定 *)
  let alert_message _ =
    Dom_html.window##alert (Js.string "Button was clicked!");
    Js._false
  in
  button##.onclick := Dom_html.handler alert_message;

  Dom.appendChild Dom_html.document##.body button;

  Js._true

let _ = Dom_html.window##.onload := Dom_html.handler onload
