
# Dockerfile 解説（DB2 Community Edition ベース）

このDockerfileは、IBMのDB2 Community Edition（バージョン 12.1.1.0）をベースに、必要な初期設定・スクリプトを追加したカスタムイメージを構築するためのものです。

---

## ベースイメージの指定

```dockerfile
FROM icr.io/db2_community/db2:12.1.1.0
```

- IBM Container RegistryのDB2 Community Edition イメージを使用。

---

## 非対話モードの設定

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

- aptなどの処理を自動化する際に、対話的なプロンプトを抑制。

---

## ポート公開

```dockerfile
EXPOSE 50000
```

- DB2のデフォルト接続ポート 50000 を外部に公開。

---

## 一時ファイルやキャッシュの削除

```dockerfile
RUN rm -rf /tmp/* /var/tmp/* /root/.cache/*
```

- イメージサイズを削減し、不要なファイルによる影響を防ぐための処理。

---

## 任意の後処理スクリプトをコピー

```dockerfile
COPY docker/scripts/postprocessing.sh /var/custom/
RUN chmod +x /var/custom/postprocessing.sh
```

- DB2インスタンス実行後に行うカスタム処理を記述したスクリプトを `/var/custom` に配置し、実行可能にする。

---

## DB2インスタンスセットアップスクリプトの修正

```dockerfile
COPY docker/scripts/setup_db2_instance.sh /var/db2_setup/lib/
RUN chmod +x /var/db2_setup/lib/setup_db2_instance.sh
```

- 公式イメージに含まれる `setup_db2_instance.sh` は不具合があるため、修正版で上書き。
- 参考: [IBM Community Discussion](https://community.ibm.com/community/user/discussion/121-container-community-edition-docker-start-fails-dbi20187e)

---

## エントリーポイントの設定

```dockerfile
COPY docker/scripts/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
```

- コンテナ起動時に実行されるエントリーポイントを自作スクリプトで置き換え。
- 起動時の初期処理やカスタム処理をここで行う。

