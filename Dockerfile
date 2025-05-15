FROM icr.io/db2_community/db2:12.1.1.0

ENV DEBIAN_FRONTEND=noninteractive

# ポート公開（DB2）
EXPOSE 50000

# キャッシュ等削除
RUN rm -rf /tmp/* /var/tmp/* /root/.cache/*

# (任意)db2インスタンス実行後に処理したいスクリプトをコピー
COPY docker/scripts/postprocessing.sh /var/custom/
RUN chmod +x /var/custom/postprocessing.sh

# Db2サーバ起動用スクリプトのコピー(以下リンクの問題から、コンテナ内部のスクリプト修正版は上書き)
# https://community.ibm.com/community/user/discussion/121-container-community-edition-docker-start-fails-dbi20187e
COPY docker/scripts/setup_db2_instance.sh /var/db2_setup/lib/
RUN chmod +x /var/db2_setup/lib/setup_db2_instance.sh

# エントリーポイントの設定
COPY docker/scripts/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
