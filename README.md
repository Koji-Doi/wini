# WINI -- HTML live standard準拠の軽量高性能マークアップ言語Markgaabのサポートツール / Supporting tool of "Markgaab", a light-weight but powerful HTML-live-standard compartible markup language 

Wini.pm ver.0を既に触って下さった方は、ver.0とver.1との違いをまとめたVersion0to1.mdも参照していただきたい。

## 概要 / Summary

Markgaabとは、HTML(WHATWG Living Standard)出力に特化した高性能かつ軽量なマークアップ言語である。名称は"Markup Going Above And Beyond"に由来する。

Wini.pmはmarkgaabで書かれたテキストをHTML Live Standard準拠のウェブページに変換するツールである。

WINIという名称は”WIKI ni NIta nanika"に由来する。

Markgaab is a lightweight markup language designed to facilitate the creation of HTML(WHATWG Living Standard)-based documents.

Wini.pm is a tool that converts text written in Markgaab into HTML Live Standard compliant web pages.

This script is a Perl library module file, and can also be used as a filter command.

### markgaabとは / What is markgaab?

* 文法を知らなくても内容を把握できる。
* 文法の習得が容易。視覚的な分かりやすさが重視されていて理解がたやすい。
* データ作成が容易。簡潔なマークアップ文字をプレインテキストに挿入していくのみなので、執筆に神経を集中できる。
* HTMLへの変換を前提とし、HTML live standardの文法、論理マークアップと物理マークアップの区別などが自然に反映できるよう配慮している。
* markdownなども参考に独自の文法を追加している。特に作表関係に多くの工夫が施されている。

* Can grasp the content without knowing grammar.
* Easy to learn grammar. Easy to understand due to the emphasis on visual clarity.
* Easy data creation. You can concentrate on writing because you only need to insert simple markup characters into the plain text.
* The grammar of HTML live standard, distinction between logical and physical markup, etc., are naturally reflected in the HTML conversion premise.
* The original syntax is added with reference to markdown and other languages. Many innovations have been made, especially in the area of table formatting.

## スタートアップ / Start Up

1. 何はともあれ、perl5.9.5以上が使える環境を用意する。WindowsであればWindows Susystem for Linux (WSL)とubuntuの導入をお勧めする。これでperlと幾つもの有用なテキスト処理用ツールが使えるようになる。winiを実装したwini.pmは、perl本体とperlの標準モジュールがあれば利用できる。
0. 次に当レポジトリをダウンロードして適当なディレクトリに展開する。
0. 上記ディレクトリ内で、`perl Wini.pm < test.wini > out.html`を実行する。test.htmlと同一内容のout.htmlができていれば、ひとまず環境設定に問題は無いだろう。
0. 必要に応じてwini.pmをperlのライブラリモジュールを格納しているディレクトリにコピーする。これで自作スクリプト中で`use Wini;`することによりwini変換関数が利用できるようになる。

```
```

1. Prepare the environment where perl 5.9.5 or later can be used. For Windows users, Windows Subsystem for Linux (WSL) and ubuntu are highly recommended.
0. Download this registry, and extend (unzip) files in an appropriate directory.
0. Try `perl Wini.pm < test.wini > out.html`. If the result out.html is the same as test.html in the registry, it is ready to start wini operating. Try `perl Wini.pm -h` to find out detailed usage of wini.pm. Refer wini.md to find out the detailed grammar of WINI. (In preparation)
0. If necessary, copy Wini.pm to the directory listed in @INC to use wini.pm as a module file.  Markgaab translation function named to_html() and supporting functions in Wini.pm will be available in perl scripts, by adding `use Wini;`.

## 詳しくは / For further information

コマンドライン上で`Wini.pm -h wini`を実行するとWini.pmの簡単な使い方が表示される。また、`Wini.pm -h mg`を実行すると文法の概略が表示される。markgaabの詳細については [qiitaの解説記事](https://qiita.com/doikoji/items/f6139b7d91b48e50dcef) を参照してほしい。

To find out the usage of Wini.pm, try `Wini.pm -h wini`. To find out the outline of markgaab grammar, try `Wini.pm -h mg`. Details will be addressed in English in the document coming soon.

Translated with www.DeepL.com/Translator (free version)
