SQLのlike句でテキスト検索する

　遅いともっぱらの噂である`like`句を使う。

<!-- more -->

# ブツ

* [リポジトリ][]

[リポジトリ]:https://github.com/ytyaru/Sqlite3.Search.Like.20221030144307

　DBファイルは[][]で入手したSQLite3のもの。内容は私が書いたモナレッジの記事。

[]:

## 実行

```sh
NAME='Sqlite3.Search.Like.20221030144307'
git clone https://github.com/ytyaru/$NAME
cd $NAME/src
./example.sh
./run モナコイン マイニング
```

# コード抜粋

## 1. sqlite3コマンドでDBファイルを開く

```sh
sqlite3 monaledge.db
```

## 2. SQL文で検索する

　本文`content`の中に`検索`というワードが含まれているレコードの`id`と`title`を取得する。

```sql
select id, title from articles where content like '%検索%';
```

　ヒットした本文の一部も表示したい。ヒットした単語から20字までを表示する。

```sql
select id, title, substr(content, instr(content, '検索'), 20) from articles where content like '%検索%';
```

　ヒットした単語の前後30字までを表示したい。

```sql
select id, title, substr(content, max(0, instr(content, '検索') - 15), 30) from articles where content like '%検索%';
```

　ヒットしたワードを強調表示したい。強調はHTMLの`<mark>`を使うこととする。

```sql
select id, title, replace(substr(content, max(0, instr(content, '検索') - 15), 30), '検索', '<mark>検索</mark>') from articles where content like '%検索%';
```

　改行コードやタブを削除する。改行コードLFは`char(10)`、CRは`char(13)`、タブは`char(9)`。

```sql
replace(content, char(10), '')
```

```sql
select id, title, replace(replace(replace(replace(substr(content, max(0, instr(content, '検索') - 15), 30), '検索', '<mark>検索</mark>'), char(10), ''), char(13), ''), char(9), '') from articles where content like '%検索%';
```

　できた。SQLite3の関数を使えば何とかなる。コードは汚いけど。

　データが少ないせいかパフォーマンスもまったく気にならない。いや、RAMディスクで実行しているせいかな。

## 3. コマンドにする

　検索したい単語を半角スペースで区切って入力する。

```sh
./run.sh モナコイン マイニング
```

　複数の引数があれば`AND`条件で検索する。以下のようにSQL文の一部を作る。

```sh
Like() { L=; for v in "$@"; do { L+=" content like '%$v%' and"; } done; echo "${L%and}"; }
```

　以下のようなSQL文になる。`replace`のウザさが異常。

```sql
SQL="select id, title, replace(replace(replace(replace(substr(content, max(0, instr(content, '$1') - 15), 30), '$1', '<mark>$1</mark>'), char(10), ''), char(13), ''), char(9), '') from articles where $(Like "$@");"
```

　複数の語で検索できるが、本文の強調は最初の語のみ。

# 結果

　`example.sh`を実行すると`モナコイン マイニング`の2語で検索する。結果は以下。

```sh
14	175
352	モナコインを獲得する方法とサイト集	取引所で口座を開設し、日本円で<mark>モナコイン</mark>を買う）3. 寄付
354	モナコインの使い道	　早速<mark>モナコイン</mark>を頂けたので、その使い道について調べてみた
376	暗号通貨の用語まとめ【ビギナー編】	てのもの。[暗号通貨][]|<mark>モナコイン</mark>やビットコインのこと
418	私は薄汚い消費者である	そらします。　私は暗号通貨<mark>モナコイン</mark>に手を出しました。そ
420	モナコインの取引トランザクションを取得する方法を調べた	やって取得しているのか。　<mark>モナコイン</mark>の取引情報はマイニン
430	Mastering Bitcoin 日本語訳PDFを読んでみる（UXTO）	e --># 経緯　[<mark>モナコイン</mark>の取引トランザクショ
432	MasteringBitcoin日本語訳を読む（トランザクション手数料）	 --># 前回* [<mark>モナコイン</mark>の取引トランザクショ
436	MasteringBitcoin日本語訳を読む（Bitcoinマイニング）	います」ともある。これって、[<mark>モナコイン</mark>の取引トランザクショ
437	MasteringBitcoin日本語訳を読む（トランザクションの使用）	的なチェックなのだろう。　<mark>モナコイン</mark>公式ツール[mona
439	総支払額を算出する方法の考察1	レイヤー (Bitcoin や<mark>モナコイン</mark>) の情報は一部しか
453	ラズパイ4でモナコインをマイニングしてみた【vippool】	re --># 結論　<mark>モナコイン</mark>を手に入れる方法とし
454	モナコインを送金する方法を調べた	し、[mpurse][]なしで<mark>モナコイン</mark>の送金を実現したい。
456	MasteringBitcoin日本語訳を読む（Script言語）	できるようになった。* [<mark>モナコイン</mark>取引集計＋取引ユーザ
457	MasteringBitcoin日本語訳を読む（標準的なトランザクション）	hain.info/doc[<mark>モナコイン</mark>公式サイト]:htt
```

　一行目一列目の`14`はヒットしたレコード数。二列目は全レコード数。つまり検索ワードにヒットしたのは175記事中14記事あったということ。

　二行目以降はレコードの値。TSV形式。ID、タイトル、本文抜粋の３列ある。このうち本文中に見つかった最初の検索ワードだけは`<mark>`タグで囲われている。

# 改善点

* 本文だけでなくタイトルでも同様にLIKE句検索すべき
* ソートもすべき：`order by updated desc`等

　やらなくても大体いい感じになるので省略した。

# 所感

　データ量が少ないおかげでRAMディスクにも配置できるので超高速。一瞬で表示された。パフォーマンス的にまったく問題なかった。

　いつまでそれで済むか。たぶん自分の記事なら一生分くらいあっても何とかなる気もする。

　本当は「うわーLIKE句おそすぎるわ〜これはFTS5使うしかないわ〜」という流れにしたかったのだが、必要性を感じられなかった。

　でも一応勉強もかねてFTS5について調査してみよう。

