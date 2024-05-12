# learn-jsoo

Trying out HTML DOM manipulation with js_of_ocaml/ocaml.

## 概要

js_of_ocaml/ocaml の dom 操作を試してみる．

本稿では OCaml の標準的なビルドシステムである
dune を用いる．
js_of_ocaml を使うのに dune は必須ではないが，
dune がある方が js_of_ocaml を用いる際もそうでない際も便利なため．

# Memo

## Prerequests

opam, dune, node が必要．

[opam](https://opam.ocaml.org/) のインストール．
以下を参考に行う．
https://opam.ocaml.org/doc/Install.html

[dune](https://dune.build/) のインストール．

```bash
opam install dune
```

[node](https://nodejs.org/en) は必須ではないが，
手元で動かしてみるときに使うのでインストールされたし．

---

本稿は基本的な OCaml, JavaScript/HTML の知識はあるものと仮定する．
dune の使用経験はなくとも理解できることを目指す．
js_of_ocaml の利用経験はないものと仮定する．

## dune を用いて初期セットアップをする．

dune を用いて初期セットアップをする．

```bash
dune init project dom_jsoo .
```

以下のようなディレクトリ構成になる．

```
tree
.
├── _build
│   └── log
├── bin
│   ├── dune
│   └── main.ml
├── dom_jsoo.opam
├── dune-project
├── lib
│   └── dune
└── test
    ├── dune
    └── test_dom_jsoo.ml
```

bin/main.ml
を見てみると，以下のようなコードになっているので，
実行すると `Hello, World!` が標準出力されるはずである．

```ocaml
let () = print_endline "Hello, World!"
```

dune は，
`dune build` でビルドができる．
また，`dune exec <project name>` でビルドが未完了だった場合はビルドをしてから実行することができる．

```bash
dune exec dom_jsoo
# Hello, World!
```

実行すると `Hello, World!` が標準出力された．

## js_of_ocaml を追加する

js_of_ocaml を追加してみよう．

dune に js_of_ocaml を追加する方法について，
dune の公式ドキュメントには以下に簡単にまとめられている．
https://dune.readthedocs.io/en/stable/jsoo.html

まず dune-project の depends に js_of_ocaml-compiler を足す．

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

---

次に js_of_ocaml を用いて OCaml コードを javascript に変換してみる．

`bin` ディレクトリをそのまま利用しても良いけど，
今回は別のものを作ることにする．

foo ディレクトリを新たに作って，foo/bar.ml, foo/dune を配置する．

```bash
mkdir foo
```

foo/bar.ml

```ocaml
let () = print_endline "hello from js"
```

foo/dune

```lisp
(executable
  (name bar)
  (modes js)
  )
```

ビルドすると，
`_build/default/foo/` ディレクトリに
`bar.bc.js` という JavaScript コードが生成されているはずである．
これを node で実行すると `hello from js` が標準出力される．

```bash
dune build
node _build/default/foo/bar.bc.js
# hello from js
```

## HTML ファイルから呼び出してみる．

先の OCaml からコンパイルされた JavaScript コードを HTML ファイルから呼び出してみる．
docs ディレクトリを生成して docs/index.html ファイルを配置する．

```bash
mkdir docs # docs である必要はないが github pages で deploy しやすいため．
```

docs/index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
    <script src="bar.bc.js"></script>
  </head>
  <body>
    <h1>Trying out HTML DOM manipulation with js_of_ocaml/ocaml.</h1>
  </body>
</html>
```

docs ディレクトリに bar.bc.js ファイルを配置する．

```bash
cp _build/default/foo/bar.bc.js docs # 二回目からは permission denied になるので sudo をつける．
```

docs/index.html をブラウザで開くとコンソール出力されているはずである．

```
open docs/index.html
```

docs/index.html をブラウザで開いてから，
google chrome の場合は右クリックして inspect を押して，
Console タブを開く．

```
hello from js
```

こんな感じの表示になっているはず．

## Managing dom: retrieving a dom element.

OCaml から id を指定して HTML の dom 要素を取得して，
その innerText をコンソールに表示してみよう．

js_of_ocaml-ppx も用いるので，
まずはこれも依存関係に追加してインストールしてやる必要がある．

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

これでインストールはできた．

foo ディレクトリ内で，
今回は js_of_ocaml モジュールと js_of_ocaml-ppx プリプロセッサを用いるので，
foo/dune ファイルも以下のように更新してやる．

foo/dune

```lisp
(executable
  (name bar)
  (modes js)
  (preprocess (pps js_of_ocaml-ppx)) ;; added
  (libraries js_of_ocaml) ;; added
  )
```

これで依存するライブラリが使えるようになった．

---

docs/index.html に id を付与した dom 要素
`<div id="hello-elem-id">Hello from HTML.</div>`
を追加した．

docs/index.html

```html
<!DOCTYPE html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
    <script src="bar.bc.js"></script>
  </head>
  <body>
    <h1>Trying out HTML DOM manipulation with js_of_ocaml/ocaml.</h1>
    <div id="hello-elem-id">Hello from HTML.</div>
  </body>
</html>
```

---

今回 OCaml で書きたいコードは，
JavaScript で書くなら以下のようになる．

```javascript
const onload = () =>
  const element = document.getElementById("hello-elem-id");
  const str = element.innerText;
  console.log(str);
  return true;

window.onload = onload;
```

js_of_ocaml の DOM 操作のドキュメントは以下にある．
https://ocsigen.org/js_of_ocaml/latest/api/js_of_ocaml/Js_of_ocaml/Dom_html/index.html
これを解読しながら実装を進めていくことになる．

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
element##.innerText
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
`Js.to_string: js_string t -> string` を用いる．

ここで，js_of_ocaml/ocaml に関係なく，
DOM 要素の取得は，ブラウザ上で DOM ツリーの構築が完了してから出ないとできない．
従って，DOM 要素を取得するような処理は，
例えば
[window.onload](https://developer.mozilla.org/en-US/docs/Web/API/Window/load_event)
イベントリスナーに登録するなどして，
DOM 構築が完了してから行われるようにしてやる必要がある．

window.onload イベントリスナーに登録するのには以下のようにしてやれば良い．

```ocaml
let onload _ =
  (* some side effects. *)
  Js._true

let _ =
  Dom_html.window##.onload := Dom_html.handler onload
```

---

最後に実際の実装はこのようになる．

foo/bar.ml

```ocaml
open Js_of_ocaml

let onload _ =
  let element = Dom_html.getElementById_exn "hello-elem-id" in
  let str = Js.to_string element##.innerText in
  print_endline str;
  Js._true

let _ = Dom_html.window##.onload := Dom_html.handler onload
```

実装が完了したら，
ビルドして，
生成された JavaScript コードを HTML ファイルが呼び出せるように配置して，
ブラウザから見てみよう．

```bash
dune build
sudo cp _build/default/foo/bar.bc.js docs # 二回目からは permission denied になるので sudo をつける．
open docs/index.html
```

Console を開くと，

```
Hello from HTML
```

が表示される．

## Managing dom: adding a dom element.

foo/bar.ml
に以下を追加する．

```ocaml
open Js_of_ocaml

let onload _ =
  (* const element = document.createElement("div"); *)
  let document = Dom_html.window##.document in
  let element = Dom_html.createDiv document in
  element##.innerText := Js.string "Newly added text.";
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

## Managing dom: adding a button.

押すと押すと自分自身を削除するボタンを追加するボタンを実装する．

## CSS

## memo

linting opam file.

```bash
opam lint *.opam
```

An Introduction to js_of_ocaml

- https://hackmd.io/@Swerve/HyhrqnFeF

https://github.com/camlspotter/ocaml-zippy-tutorial-in-japanese/blob/master/js_of_ocaml.rst
