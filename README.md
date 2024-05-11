# learn-jsoo

Trying out HTML DOM manipulation with js_of_ocaml/ocaml.

## 概要

js_of_ocaml/ocaml の dom 操作を試してみる．

# Memo

## Initial setup

```bash
dune init project dom_jsoo .
```

```bash
dune exec dom_jsoo
# Hello, World!
```

## Adding js_of_ocaml

https://dune.readthedocs.io/en/stable/jsoo.html

dune-project の depends に js_of_ocaml-compiler を足す．

```diff
< (depends ocaml dune)
---
> (depends
>   ocaml
>   dune
>   js_of_ocaml-compiler
>   )
```

```bash
dune build
```

をすると，opam ファイルに反映されるはず．

```opam
depends: [
  "ocaml"
  "dune" {>= "3.15"}
  "js_of_ocaml-compiler" # newly added
  "odoc" {with-doc}
]
```

```bash
opam install .
```

をすると js_of_ocaml-compiler が install される．

```
[dom_jsoo.~dev] synchronised (no changes)
Constructing initial basis...
Number of 0-1 knapsack inequalities = 2874
Constructing conflict graph...
Conflict graph has 888 + 474 = 1362 vertices
The following actions will be performed:
  - install js_of_ocaml-compiler 5.7.2 [required by dom_jsoo]
  - install dom_jsoo             ~dev*
===== 2 to install =====
Do you want to continue? [Y/n] Y

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><><><>
-> retrieved dom_jsoo.~dev  (file:///Users/sano/work/dev/learn-jsoo/dom_jsoo)
-> retrieved js_of_ocaml-compiler.5.7.2  (cached)
-> installed js_of_ocaml-compiler.5.7.2
-> installed dom_jsoo.~dev
Done.
```

javascript に変換してみる．

bin directory のものを利用しても良いけど，
今回は別のものを作ることにする．

```bash
mkdir foo
cd foo

vim bar.ml # edit
cat bar.ml
# let () = print_endline "hello from js"

vim dune # edit
cat dune
# (executable
#   (name bar)
#   (modes js)
#   )

dune build
node _build/default/foo/bar.bc.js
# hello from js
```

## Adding HTML

```bash
mkdir docs # docs である必要はないが github pages で deploy しやすいため．
```

docs/index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
    <h1>Trying out HTML DOM manipulation with js_of_ocaml/ocaml.</h1>
    <script src="bar.bc.js"></script>
  </body>
</html>
```

```bash
cp _build/default/foo/bar.bc.js docs # 二回目からは permission denied になるので sudo をつける．
open docs/index.html
```

google chrome の場合は右クリックして inspect を押して，
Console タブを開く．

```
hello from js
```

こんな感じの表示になっているはず．

## Managing dom: retrieving a dom element.

HTML から id を指定して dom 要素を取得して，
その innerText をコンソールに表示してみよう．

html に id を付与した dom 要素
`<div id="hello-elem-id">Hello from HTML.</div>`
を追加した．

docs/index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
    <h1>Trying out HTML DOM manipulation with js_of_ocaml/ocaml.</h1>
    <div id="hello-elem-id">Hello from HTML.</div>
    <script src="bar.bc.js"></script>
  </body>
</html>
```

https://ocsigen.org/js_of_ocaml/latest/api/js_of_ocaml/Js_of_ocaml/Dom_html/index.html

install js_of_ocaml and js_of_ocaml-ppx.

dune-project

```
 (depends
   ocaml
   dune
   js_of_ocaml-compiler
   js_of_ocaml # newly added
   js_of_ocaml-ppx # newly added
   )
```

```bash
dune build # update opam file
opam install .
```

foo/dune

```lisp
(executable
  (name bar)
  (modes js)
  (libraries js_of_ocaml) ;; added
  )
```

https://ocsigen.org/js_of_ocaml/latest/api/js_of_ocaml/Js_of_ocaml/Dom_html/index.html#val-getElementById_exn

```ocaml
val getElementById_exn : string -> element Js.t
(** [getElementById_exn id] returns the element with the id id in the current document.
    It raises if there are no such element *)
```

これを使って dom element を取得した後に，
innerText を読み出す．

https://ocsigen.org/js_of_ocaml/latest/api/js_of_ocaml/Js_of_ocaml/Dom_html/class-type-htmlElement/index.html#method-innerText

```ocaml
method innerText : Js_of_ocaml__.Js.js_string Js_of_ocaml__.Js.t
                     Js_of_ocaml__.Js.prop
```

js_of_ocaml-ppx を用いると，

```ocaml
elem##.innerText
```

のように `##.` を使って innerText にアクセスすることができる．
この詳細は以下に詳しい．
https://ocsigen.org/js_of_ocaml/latest/manual/ppx
ちなみに `.pp.ml` ファイルは謎のバイナリファイルと化していて，
正常な OCaml ソースコードではなかった．
ちょっと調べたがさっぱり理解できず．

ただし，これによって返されるのは OCaml ではなく，
JavaScript の文字列であるので，
OCaml の文字列に変換してやりたいときは
`Js.to_string` を用いる．

実際の実装はこのようになる．

foo/bar.ml

```ocaml
open Js_of_ocaml

let () =
  let elem = Dom_html.getElementById_exn "hello-elem-id" in
  let str = Js.to_string elem##.innerText in
  print_endline str
```

```bash
dune build
cp _build/default/foo/bar.bc.js docs # 二回目からは permission denied になるので sudo をつける．
open docs/index.html
```

inspect → console を開くと，

```
Hello from HTML
```

が表示される．

## Managing dom: adding a dom element.

foo/bar.ml
に以下を追加する．

```ocaml
  (* const element = document.createElement("div"); *)
  let element = Dom_html.createDiv Dom_html.window##.document in
  element##.innerText := Js.string "Newly added text.";
  Dom.appendChild Dom_html.document##.body element
```

open docs/index.html
すると，

> # Trying out HTML DOM manipulation with js_of_ocaml/ocaml.
>
> Hello from HTML.
>
> Newly added text.

となる．

## Managing dom: adding a button.

```ocaml
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

  Dom.appendChild Dom_html.document##.body button
```

## memo

linting opam file.

```bash
opam lint *.opam
```

An Introduction to js_of_ocaml

- https://hackmd.io/@Swerve/HyhrqnFeF

https://github.com/camlspotter/ocaml-zippy-tutorial-in-japanese/blob/master/js_of_ocaml.rst
