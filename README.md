# [mydb2](https://github.com/shindy-dev/mydb2)

## Abstract
*Docker* を使用した *Db2* 勉強用リポジトリ

下記不具合修正版  
[12.1 container Community Edition docker start fails DBI20187E](https://community.ibm.com/community/user/discussion/121-container-community-edition-docker-start-fails-dbi20187e)

## Environment
- ### *[Docker Desktop](https://www.docker.com/ja-jp/products/docker-desktop/) on macOS*
    version 28.0.4, build b8034c0

    Docker Image：[ghcr.io/shindy-dev/mydb2:12.1.1.0](https://github.com/shindy-dev/mydb2/pkgs/container/mydb2)  
    継承元：[Db2 Community Edition for Docker](https://www.ibm.com/docs/ja/db2/11.5.x?topic=deployments-db2-community-edition-docker) (Red Hat Enterprise Linux 9)  
    
    tips. [How to build Docker Image](docs/how2_build_DockerImage.md)  

## How to build Environment
### 1. Pull Image
```bash
docker pull ghcr.io/shindy-dev/mydb2:12.1.1.0 --platform=linux/amd64
```

---

### 2. Create *.env* for *db2*
秘匿化が必要な設定を.envファイルに記載する  
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
参考：[macOS システムへの Db2 Community Edition Docker イメージのインストール](https://www.ibm.com/docs/ja/db2/11.5.x?topic=system-macos)

---

### 3. Boot Container

#### Create Custome Network
```bash
# コンテナ間通信用ネットワーク作成
docker network create mynet
```

#### Run Container

```bash
# デーモンプロセスとしてコンテナ起動
docker run -itd -h mydb2 --name mydb2 --restart=always --privileged -p 50000:50000 --env-file ~/.env --network mynet --platform=linux/amd64 ghcr.io/shindy-dev/mydb2:12.1.1.0
```

- `-itd`: インタラクティブ・バックグラウンドモード
- `-h`: ホスト名の設定
- `--name`: コンテナ名をに指定
- `--restart=always`: 自動再起動設定
- `--privileged`: 特権モードで起動
- `-p`: ポートマッピング(50000はdb2サーバのポート)
- `--env-file`: 環境変数を `.env` ファイルから設定
- `--network`: ネットワークを指定
- `--platform`: 明示的にプラットフォームを指定
- `ghcr.io/shindy-dev/mydb2:12.1.1.0`: 使用Image

---
#### Execute Container
```bash
# /bin/bashで実行
docker exec -it mydb2 /bin/bash
```
---
#### Remove & Run & Execute Container
- macOS  
    ```bash
    docker stop mydb2 || true && docker rm mydb2 || true && \
    docker run -itd -h mydb2 --name mydb2 --restart=always \
    --privileged -p 50000:50000 --env-file .env --network mynet \
    --platform=linux/amd64 ghcr.io/shindy-dev/mydb2:12.1.1.0 && \
    docker exec -it mydb2 /bin/bash
    ```

- Windows
    ```powershell
    docker stop mydb2
    docker rm mydb2
    
    docker run -itd -h mydb2 --name mydb2 --restart=always `
    --privileged -p 50000:50000 --env-file ".env" --network mynet `
    --platform=linux/amd64 ghcr.io/shindy-dev/mydb2:12.1.1.0

    docker exec -it mydb2 /bin/bash
    ```

## References
* [macOS システムへの Db2 Community Edition Docker イメージのインストール](https://www.ibm.com/docs/ja/db2/11.5.x?topic=system-macos)
* [Mac M1 Docker DesktopでDb2を動かす #db2 - Qiita](https://qiita.com/kayokok/items/0d23efeece19c4f31e8b)