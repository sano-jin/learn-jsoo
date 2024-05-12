open Js_of_ocaml
module Html = Dom_html

let onload _ =
  let s = Js.string in
  let document = Html.window##.document in
  let parent = Html.document##.body in
  let append_button text onclick =
    let button =
      Html.createButton ~_type:(s "button") ~name:(s "button") document
    in
    button##.innerText := s text;
    button##.onclick := Html.handler onclick;
    Dom.appendChild parent button
  in

  let delete_itself event =
    ignore @@ Js.Opt.map event##.target @@ Dom.removeChild parent;
    Js._false
  in

  let counter = ref 0 in
  let add_button _ =
    incr counter;
    let i = !counter in
    let text = "button " ^ string_of_int i in
    append_button text delete_itself;
    Js._false
  in

  append_button "add a button." add_button;
  Js._true

let _ = Html.window##.onload := Html.handler onload
