# インストール方法

このリポジトリをデスクトップなどに置く。

powershellを管理者権限で実行。

~~~
PS> wsl --install
PS> wsl # wslのシェルが開く
~~~

以下、wslのシェルで行う。

~~~
$ cd <このリポジトリ>
$ stack ghci # Haskellのインタプリタのプロンプトが開く。
~~~

# プロジェクト特有の設定

`/script/src/Project.hs`を修正する。

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

# SSHの公開鍵の登録

初回の接続は公開鍵をリモートホストに登録する必要がある。

~~~
GHCi> sshCopyID "mega@172.21.101.1"
~~~

などとして登録できる。

# ローカルの実行体の場所を指定する

`/script/src/Script.hs`内の以下の変数を書き換える：

~~~
srcFileDir :: FilePath
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-17-ew-ahmedabad"
~~~

# 使えるコマンド

`/script/src/Script.hs`とか`/script/src/Util.hs`を参照。
