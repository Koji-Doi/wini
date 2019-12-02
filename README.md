# WINI -- wikiマークアップに似た使いやすいマークアップ言語 / A simple, useful, wiki-markup-like and highly-html5-compatible markup language 

## 概要 / Summary
WINIとは、WIKI markupを参考に、より簡単に、より便利に、HTML5ベースの文書作成ができるように設計された、軽量マークアップ言語である。
WINIという名称は”WIKI ni NIta nanika"に由来する。

WINIで書かれたテキストは、そのままの形で蓄積・活用しても良いが、wini.pmというツールを用いてHTML5形式のテキストに変換するのが基本手順である。

### WINIとは / What is WINI?
WINIは、前述の通りwiki markupを参考に開発され、簡易マークアップ言語としての多くの長所を共有している。

* 文法を知らなくても内容を把握できる。
* 文法の習得が容易。視覚的な分かりやすさが重視されていて理解がたやすい。
* データ作成が容易。簡潔なマークアップ文字をプレインテキストに挿入していくのみなので、執筆に神経を集中できる。

その上で、WINIはもちろん幾つかの特徴を有している。

* HTML5への変換を前提とし、HTML5で変更された文法、論理マークアップと物理マークアップの区別などが自然に反映できるよう配慮している。
* markdownなども参考に独自の文法を追加している。特に作表関係に多くの工夫が施されている。
* perlさえあればHTML5ファイルの作成が容易。

WINI is a new markup language designed with reference to wiki markup. Thus, WINI grammar is very similar to that of wiki. The name 'WINI' stands for "WIki ni NIta nanika", which means "something like wiki" in Japanese.

The script file wini.pm is a perl module supporting WINI markup. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using wini.pm as a filter command.

WINI is designed with reference to wiki markup as mentioned above, and thus several strong points are inherited from existing markup languages. 

* Readers can grip the contents  intuitively, even if they are not familiar with WINI grammer.
* WINI grammer is simple and easy to learn by visual analogy.
* Type setting can be easily achieved by insertion of simple markup characters into plain text.

At the same time WINI has some  strong points such as:

* High HTML5 compatibility:  WINI is designed with a strong emphasis on affinity with HTML5 and easiness of complex HTML table construction.
* Original establishment of grammer, especially for table construction. 

### wini.pmとは / What is wini.pm?

wini.pmはWINIによるタイプセッティングを実現するためのperl moduleもしくはスクリプトである。ライブラリとして他のperlスクリプトから利用できるのはもちろん、単体でWINI→HTML5の変換用フィルタコマンドとして利用できるように作られている。

The script file wini.pm is a perl module supporting WINI markup. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using wini.pm as a filter command.

## スタートアップ / Start Up

1. 何はともあれ、perl5.8.1以上が使える環境を用意する。winiを実装したwini.pmは、perl本体とperlの標準モジュールがあれば利用できる。
0. 次に当レポジトリをダウンロードして適当なディレクトリに展開する。
0. 上記ディレクトリ内で、`perl wini.pm < test.wini > out.html`を実行する。test.htmlと同一内容のout.htmlができていれば、ひとまず環境設定に問題は無いだろう。perl.pmの詳しい使い方については`perl wini.pm -h`で表示されるヘルプを参照してほしい。winiマークアップの文法についてはwini-j.mdまたはwini.mdを参照してほしい。(In preparation)
0. 必要に応じてperl.pmをperlのライブラリモジュールを格納しているディレクトリにコピーする。これで自作スクリプト中で`use wini;`することによりwini変換関数が利用できるようになる。

1. Prepare the environment where perl 5.8.1 or later can be used.
0. Download this registry, and extend (unzip) files in an appropriate directory.
0. Try `perl wini.pm < test.wini > out.html`. If the result out.html is the same as test.html in the registry, it is ready to start wini operating. Try `perl wini.pm -h` to find out detailed usage of wini.pm. Refer wini.md to find out the detailed grammar of WINI. (In preparation)
0. If necessary, copy wini.pm to the directory listed in @INC to use wini.pm as a module file.  WINI translation functions in wini.pm will be available in perl scripts, by adding `use wini;`.
