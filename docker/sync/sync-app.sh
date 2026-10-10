#!/bin/sh
# Windows 側のフォルダ（/host = api）と、コンテナ内の速い領域（/app）を双方向にそろえる。
#
# なぜ必要か：Docker Desktop で Windows のフォルダを直接読むと、ファイル1つの確認に数ミリ秒かかる。
# Rails は、リクエストのたびに「ソースが変わっていないか」を多くのファイルで確かめるので、
# 直接つなぐと表示に 1 秒前後、テストに 1 分以上かかる。
# そこで Rails には /app（速い）を読ませ、/host とは 2 秒おきにそろえる。
#
#   sync-app once   1回だけそろえて終わる（初回の準備で使う）
#   sync-app watch  そろえ続ける（普段はこれ）
set -u

MODE="${1:-watch}"
READY=/state/ready
rm -f "$READY"

if [ ! -f /host/Gemfile ]; then
    echo "[sync] /host に Gemfile が見つかりません。api フォルダを確認してください。" >&2
    exit 1
fi

# Rails が書き込むフォルダは同期しないので、先に作っておく
mkdir -p /app/tmp/pids /app/tmp/cache /app/log /app/storage

run_unison() {
    # -batch          質問せずに進める
    # -prefer newer   両方で同じファイルを変えたときは、新しいほうを採用する
    # -times          更新日時もそろえる（どちらが新しいかを正しく比べるため）
    # -perms 0        Windows 側は権限を持てないので、権限はそろえない
    # 片方のフォルダが丸ごと空に見えるときは、unison が安全のために止まる（全消しを防ぐ既定の動き）
    unison /host /app \
        -batch -auto -prefer newer -times -perms 0 -dontchmod \
        -fastcheck true -links false -terse -log=false \
        -ignore 'Path tmp' \
        -ignore 'Path log' \
        -ignore 'Path storage' \
        -ignore 'Path vendor/bundle' \
        -ignore 'Path coverage' \
        -ignore 'Path .bundle' \
        -ignore 'Name .git' \
        -ignore 'Name *.tmp' \
        "$@"
}

echo "[sync] 最初の同期をしています..."
run_unison
code=$?
# 0 = 差分なし・すべて成功、1 = 一部を見送り（次の回でそろう）、2 以上 = 失敗
if [ "$code" -ge 2 ]; then
    echo "[sync] 同期に失敗しました（終了コード $code）。" >&2
    exit "$code"
fi

# bin/ の実行ファイルは、Windows 側では実行権限を持てない。コンテナ側で付け直す
chmod +x /app/bin/* 2>/dev/null || true

touch "$READY"
echo "[sync] 最初の同期が終わりました。"

[ "$MODE" = "once" ] && exit 0

# 2 秒おきにそろえ続ける。失敗しても止まらず、少し待ってやり直す
while true; do
    run_unison -repeat 2 -silent
    echo "[sync] 同期が止まったので、やり直します（終了コード $?）。" >&2
    sleep 3
done
