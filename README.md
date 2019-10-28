# WINI -- wikiマークアップに似た使いやすいマークアップ言語 / A simple, useful, wiki-markup-like and highly-html5-compatible markup language 

## 概要 / Summary
WINIとは、WIKI markupを参考に、より簡単に、より便利に、HTML5ベースの文書作成ができるように設計された、軽量マークアップ言語である。
WINIという名称は”WIKI ni NIta nanika"に由来する。

wini.pmはWINIによるタイプセッティングを実現するためのperl moduleもしくはスクリプトである。ライブラリとして他のperlスクリプトから利用できるのはもちろん、単体でWINI→HTML5の変換用フィルタコマンドとして利用できるように作られている。

WINIは、前述の通りwiki markupを参考に開発されたが、もちろん、wiki markupにはない（あるいは上回る）いくつかの特徴を有している。

* 直感的で簡素で理解しやすい。wiki markupと共通な部分も多く、経験者であれば習得はさらに容易だろう。しかし、wiki markupがいけてないと作者が思う部分は、markdownなども参考に独自の文法を追加している。
* HTML5への変換を念頭に置いており、クラス定義などHTML5の特徴を反映した文法構成をとる。
* pure perlで書かれたscriptで簡単にwiniテキスト→html5テキストの変換ができる。

WINI is a new markup language designed with reference to wiki markup. Thus, WINI grammar is very similar to that of wiki. The name 'WINI' stands for "WIki ni NIta nanika", which means "something like wiki" in Japanese. Otherwise, WINI has several strong points in comparison with wiki markup and other existing markup languages.

* Easiness to learn: WINI grammar is similar to that of wiki markup. The grammer is very simple. Not only persons with experience of wiki typesetting, but everyone can find out usage easily.
* HTML5 compatibility:  WINI is designed with a strong emphasis on affinity with HTML5 and easiness of complex HTML table construction. WINI is a useful system to produce modern and valid HTML5 texts quickly.
           
The script file wini.pm is a perl module supporting WINI markup. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using wini.pm as a filter command.

## スタートアップ / Start Up

0. 何はともあれ、perl5.8.0以上が使える環境を用意する。winiを実装したwini.pmは、perl本体とperlの標準モジュールがあれば利用できる。
0. 次に当レポジトリをダウンロードして適当なディレクトリに展開する。
0. 上記ディレクトリ内で、`perl wini.pm < test.wini > out.html`を実行する。
0. test.htmlと同一内容のout.htmlができていれば、ひとまずperlの設定に問題は無いだろう。
0. perl.pmの詳しい使い方については`perl wini.pm -h`で表示されるヘルプを参照してほしい。
0. 必要に応じてperl.pmをperlのライブラリモジュールを格納しているディレクトリにコピーする。これで自作スクリプト中で`use wini;`することによりwini変換関数が利用できるようになる。
0. winiマークアップの文法についてはwini-j.mdまたはwini.mdを参照してほしい。(In preparation)
