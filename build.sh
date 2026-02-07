#!/bin/sh
set -eu

. ./build

mode="${mode:-full}"
bench=public/bench.txt
bench_incr=public/bench-incremental.txt
bench_warm=public/bench-warmup.txt
measurement_version=2

write_common_metadata() {
  target="$1"
  {
    echo "build_id=$build_id"
    echo "push_ts=$push_ts"
    echo "mode=$mode"
    echo "measurement_version=$measurement_version"
  } > "$target"
}

echo "starting build $build_id (mode=$mode)"

case "$mode" in
  full)
    # No build step - static file already exists
    write_common_metadata "$bench"
    echo "start_ts=$(date +%s)" >> "$bench"
    echo "end_ts=$(date +%s)" >> "$bench"

    echo "=== Full build results ==="
    cat "$bench"
    ;;

  warm)
    # No-op for static-micro, file already exists
    write_common_metadata "$bench_warm"
    echo "start_ts=$(date +%s)" >> "$bench_warm"
    echo "end_ts=$(date +%s)" >> "$bench_warm"
    echo "warmup_complete=true" >> "$bench_warm"

    echo "=== Warmup build results ==="
    cat "$bench_warm"
    ;;

  incremental)
    # The "cache" is the pre-existing index.html
    cache_exists="true"

    # Modify the HTML file slightly for incremental test
    echo "<!-- Incremental build marker: ${build_id}-incr-$(date +%s) -->" >> public/index.html

    write_common_metadata "$bench_incr"
    echo "cache_exists=$cache_exists" >> "$bench_incr"
    echo "start_ts=$(date +%s)" >> "$bench_incr"
    echo "end_ts=$(date +%s)" >> "$bench_incr"

    echo "=== Incremental build results ==="
    cat "$bench_incr"
    ;;

  *)
    echo "Unknown mode: $mode"
    echo "Expected one of: full, warm, incremental"
    exit 1
    ;;
esac
