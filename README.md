# インストール方法

まずPCをインターネットに繋ぐ。

## WSLのインストール

powershellを管理者権限で実行。

~~~
PS> wsl --install
PS> wsl # wslのシェルが開く
~~~

## stackのインストール

以下のコマンドをwslのシェルで実行する。

~~~
$ curl -sSL https://get.haskellstack.org/ | sh
~~~

# 使い方

以下のコマンドをwslのシェルで実行する。

~~~
$ cd <このリポジトリ>
$ stack ghci # Haskellのインタプリタのプロンプトが開く。
~~~
※はじめは色々ダウンロードしてくるので少し時間がかかります。

色々なHaskellの関数が使えるようになる。

例：

~~~
GHCi> ping "172.21.101.1"
("172.21.101.1",ExitSuccess)
~~~

もっと複雑なことがやりたくなったら、`/script/src/Script.hs`を
お好みのテキストエディタで編集して自分でスクリプトを書く。

編集が完了したら、`:r`でインタプリタにリロードする。

~~~
GHCi> :r
Ok, five modules loaded.
~~~

# よく使うコマンド

~~~
removeKnownHost "172.21.101.1"
sshCopyID "172.21.101.1"
endServer "172.21.101.1"
startServer "172.21.101.1"
updateHascatsServer "172.21.101.1"
updateHascatsWorkstation "172.21.101.1"
killHascats "172.21.101.1"
reboot "172.21.101.1"
~~~

詳細は`/script/src/Script.hs`とか`/script/src/Util.hs`を参照。


# プロジェクト特有の設定

`/script/src/Project.hs`をお好みのテキストエディタで修正する。

例：

~~~
user :: Text
user = "mega"
password :: Text
password = "mega2018"
workstationBinaryName :: FilePath
workstationBinaryName = "hascats-exe-ws-ew1"
serverBinaryName :: FilePath
serverBinaryName = "hascats-exe-svr-ew1"
~~~

※`git branch -a`でそれらしいブランチがあればチェックアウトしてみると良い。

設定が完了したら、`:r`でインタプリタにリロードする。

# SSHの公開鍵の登録

初回の接続は公開鍵をリモートホストに登録する必要がある。

~~~
GHCi> sshCopyID "172.21.101.1"
~~~

などとして登録できる。

エラーが出たらとりあえず以下をやっておく。

~~~
GHCi> removeKnownHost "172.21.101.1"
~~~

# ローカルの実行体の場所を指定する

`/script/src/Script.hs`内の以下の変数を書き換える：

~~~
srcFileDir :: FilePath
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-17-ew-ahmedabad"
~~~

`updateHascatsWorkstation`や`updateHascatsServer`が自動的にそこから
実行体をアップロードしてくれるようになります。
