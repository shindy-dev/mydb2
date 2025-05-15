# [mydb2](https://github.com/shindy-dev/mydb2)

## 概要
DB2勉強用リポジトリ

## 環境
- ### [Docker Desktop](https://www.docker.com/ja-jp/products/docker-desktop/) on macOS
    version 28.0.4, build b8034c0

    今回使用するイメージ：[shindy0810/mydb2](https://hub.docker.com/r/shindy0810/mydb2)  
    ┗[Db2 Community Edition for Docker](https://www.ibm.com/docs/ja/db2/11.5.x?topic=deployments-db2-community-edition-docker)のDockerイメージ(Red Hat Enterprise Linux 9)をベースにDjango用のライブラリをインストールしたイメージ  
    ┗[どのようにイメージを作成したか](docs/build_DockerImage.md)  

    tips. Red HatはLinuxベースのOSであり、Linuxコンテナは通常Linuxカーネルに依存するため、Linux上での実行が前提となる。しかし、Docker DesktopではmacOSではLinux仮想マシン（VM）、WindowsではWSL2などの仮想基盤を用いることで、非Linux OS上でもLinuxコンテナの実行を可能としている

## 環境構築
### Dockerイメージ取得
[Docker Desktop on macOS](#Docker-Desktop-on-macOS)に記載したイメージをpull（取得）する
```bash
docker pull shindy0810/mydb2:12.1.1.0 --platform=linux/amd64
```

---

### .env作成
環境依存の設定を.envファイル（任意のパスに作成）に記載する  
※DB2を使用するために必要な設定
```
LICENSE=accept
DB2INSTANCE=db2inst1
DB2INST1_PASSWORD=db2inst1
DBNAME=
BLU=false
ENABLE_ORACLE_COMPATIBILITY=false
UPDATEAVAIL=NO
TO_CREATE_SAMPLEDB=false
REPODB=false
IS_OSXFS=true
PERSISTENT_HOME=true
HADR_ENABLED=false
ETCD_ENDPOINT=
ETCD_USERNAME=
ETCD_PASSWORD=
```

項目説明  
- LICENSE は、このイメージに含まれる Db2 ソフトウェアの契約条件に同意します。
- DB2INSTANCE は Db2 インスタンス名を指定します。
- DB2INST1_PASSWORD は、 Db2 インスタンスのパスワードを指定します。
- DBNAME は、指定された名前で初期データベースを作成します (データベースが必要ない場合は空のままにします)
- BLU は、 Db2 インスタンスの BLU Acceleration を使用可能 (true) または使用不可 (false) に設定します。
- ENABLE_ORACLE_COMPATIBILITY は、インスタンスの Oracle 互換性を有効 (true) または無効 (false) に設定します
- より高い Db2 レベルで新規コンテナーを実行している既存のインスタンスがある場合は、UPDATEAVAIL を YES に設定できます。
- TO_CREATE_SAMPLEDB は、サンプル (定義済み) データベースを作成します (true)
- REPODB は、Data Server Manager リポジトリー・データベースを作成します (true)
- IS_OSXFS は、オペレーティング・システムを macOS として認識します (true)
- PERSISTENT_HOME はデフォルトで、true に設定されており、Docker for Windows を実行している場合にのみ false として指定する必要があります
- HADR_ENABLED は、インスタンスの Db2 HADR を構成します (true)。 以下の 3 つの環境変数は、HADR_ENABLED が true に設定されていることに依存します。
- ETCD_ENDPOINT は、ユーザー自身が指定した ETCD キー値ストアを指定します。 コンマ (スペースなし) を区切り文字としてエンドポイントを入力します。 HADR_ENABLED が true に設定されている場合、この環境変数が必要です。
- ETCD_USERNAME は、ETCD のユーザー名資格情報を指定します。 空のままにすると、 Db2 インスタンスが使用されます。
- ETCD_PASSWORD は、ETCD のパスワード資格情報を指定します。 空のままにすると、 Db2 インスタンス・パスワードが使用されます。  
参考：https://www.ibm.com/docs/ja/db2/11.5.x?topic=system-macos

---

### コンテナの起動
以下のコマンドで既存のコンテナやボリューム（もしあれば）の削除、作成、コンテナに入るまでまとめて行う（「.env」のパスは適宜修正）

macOS  
```bash
docker stop mydb2 || true && docker rm mydb2 || true && \
docker run -itd -h mydb2 --name mydb2 --restart=always \
--privileged -p 50000:50000 --env-file .env \
--platform=linux/amd64 shindy0810/mydb2:12.1.1.0 && \
docker exec -it mydb2 /bin/bash
```

Windows
```powershell
docker stop mydb2
docker rm mydb2

docker run -itd -h mydb2 --name mydb2 --restart=always `
--privileged -p 50000:50000 --env-file ".env" `
--platform=linux/amd64 shindy0810/mydb2:12.1.1.0

docker exec -it mydb2 /bin/bash
```

#### 1. 停止と削除（失敗しても続行）

```bash
docker stop mydb2 || true && docker rm mydb2 || true
```

- `docker stop mydb2`: コンテナ `mydb2` を停止
- `|| true`: 失敗してもエラーを無視して続行
- `docker rm mydb2`: 停止したコンテナを削除

---

#### 2. コンテナ起動

```bash
docker run -itd -h mydb2 --name mydb2 --restart=always \
--privileged -p 50000:50000 --env-file ~/.env \
--platform=linux/amd64 shindy0810/mydb2:12.1.1.0
```

- `-itd`: インタラクティブ・バックグラウンドモード
- `-h mydb2`: ホスト名の設定
- `--name`: コンテナ名を `mydb2` に指定
- `--restart=always`: 自動再起動設定
- `--privileged`: 特権モードで起動
- `-p`: ポートマッピング(50000はdb2サーバのポート)
- `--env-file`: 環境変数を `.env` ファイルから
- `--platform`: 明示的にプラットフォームを指定
- `shindy0810/mydb2:12.1.1.0`: 使用するイメージ

---

#### 3. コンテナの中に入る

```bash
docker exec -it mydb2 /bin/bash
```

- 起動したコンテナに `bash` で入る。

## 参考文献一覧
* [Mac M1 Docker DesktopでDb2を動かす #db2 - Qiita](https://qiita.com/kayokok/items/0d23efeece19c4f31e8b)
