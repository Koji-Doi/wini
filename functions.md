
# deref() -- 「自動連番」の解決

## synopsis

「自動連番」を実現するために不可欠な関数である。

markgaab()は、図番号・表番号・文献番号などを仮形式の文字列として出力に埋め込んでいく。
deref()はその処理の後に呼び出され、それぞれの仮文字列を適切な番号を含む正式な文字列に置き換えていく。

# init() -- グローバル変数を初期化する

## usage
 
 init();

## synopsis

Wini.pmにテキスト変換をさせる場合は、あらゆる処理に先立って本関数を実行し、グローバル変数を初期化しなければならない。

# to_html() -- markgaabテキストのhtmlテキストへの変換（元締め）

## usage

 $r = to_html($mgtxt, $opt);

 $mgtxt: markgaabで書かれたテキスト
 $opt: オプションパラメータが記録されたハッシュのリファレンス
 $r: HTMLテキスト

## synopsis

markgaabテキストのhtmlテキストへの変換には、原則として当関数を利用する。
内部では次のような処理が実行される。

* 受け取ったmarkgaabテキストをセクションに分解する。
* セクションごとにmarkgaab()を呼び出してHTML変換。
* テンプレートが指定されている場合は、生成したテキストを指定テンプレートに埋め込み、HTMLドキュメントを完成させる。
* 自動連番を伴うテキストではderef()を呼び出し、図番号・表番号・文献番号などを確定させる。
* 必要ならwhole_html()を呼び出して自己完結型HTMLを生成。

# markgaab() -- markgaabテキストのHTMLテキストへの変換（下請け）

## usage

 $r = markgaab($mgtxt, $opt);

 $mgtxt: markgaabで書かれたテキスト
 $opt: オプションパラメータが記録されたハッシュのリファレンス
  $opt->{cssfile}: "<ref>"attributeに記載されるCSSファイル名
  $opt->{nocr}: 改行コードを挿入しない
  $opt->{para}: 
  $opt->{title}: ページタイトル 
  $opt->{table}: table ID
 $r: HTMLテキスト

## synopsis

* to_html()の下請けとして、markaabからHTMLへの変換を担う。
* 引用部分のリファレンス化、上付け文字・下付け文字・リンク・インラインイメージなどの処理には本関数が直接的に関与する。
* マクロが検出されたらcall_macro()を呼び出し、その中身をHTMLに変換する。
* 必要に応じてtable()およびfootnote()を呼び出し、表データを<table>を使ったHTMLに変換する。

# stand_alone() -- CLIコマンドとしてのWini.pmの機能を実現する

## synopsis

Wini.pmがモジュールとしてではなく単体のスクリプトとして使われ、コマンドラインツールとして使われる際、当関数が使用される。
当該関数はコマンドラインオプションを読み取り、適切なパラメータを設定した上でto_html()関数を呼び出す。
また、文献データファイルの読み書きが要求される場合はread_bib(), save_bib()関数を呼び出す。

# whole_html() -- ヘッダ等を付加し、自己完結したHTMLドキュメントを生成する。

## usage

 $matured_html = whole_html($raw_html, $opt);

 $raw_html: html text (probably generated by markgaab())
 $opt->{title}: page title
 $opt->{cssfile}: css file name used for '<link rel="stylesheet"' attribute 
 $opt->{cssflameworks}: url of css used for '<link rel="stylesheet"' attribute 

## synopsis

markgaab()が生成するHTMLドキュメントは入力元markgaabテキストを過不足なくHTMLに置き換えたものである。
出力結果は他のテキストと組み合わせて利用される前提であり、DOCTYPE宣言もHTMLタグも伴っていない。そのままではブラウザでの閲覧に問題が生じる可能性がある。当関数を利用することにより、自己完結したHTMLドキュメントが生成できる。