#!/bin/sh

. ./build

bench=public/bench.txt
bench_incr=public/bench-incremental.txt

echo "starting build $build_id"

# --- COLD BUILD ---
echo "build_id=$build_id" > $bench
echo "push_ts=$push_ts" >> $bench
echo "start_ts=$(date +%s)" >> $bench

# No build step - static file is already there

echo "end_ts=$(date +%s)" >> $bench

echo "=== Cold build results ==="
cat $bench

# --- INCREMENTAL BUILD ---
incremental_push_ts=$(date +%s.%N)

# Modify the HTML file slightly for incremental test
echo "<!-- Incremental build marker: ${build_id}-incr-$(date +%s) -->" >> public/index.html
echo "Modified public/index.html for incremental deploy test"

echo "build_id=$build_id" > $bench_incr
echo "push_ts=$incremental_push_ts" >> $bench_incr
echo "start_ts=$(date +%s)" >> $bench_incr
echo "end_ts=$(date +%s)" >> $bench_incr

echo "=== Incremental build results ==="
cat $bench_incr
