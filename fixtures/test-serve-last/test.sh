#!/usr/bin/env bash

content1="first file content"
content2="second file content"

setup() {
  echo "$content1" > file1.txt
  echo "$content2" > file2.txt
}

run_test() {
  # Upload first file
  curl -s -F "file=@file1.txt" localhost:8000

  # Small delay to ensure different modification times
  sleep 0.1

  # Upload second file
  curl -s -F "file=@file2.txt" localhost:8000

  # Test that /last returns the second (most recent) file
  result=$(curl -s localhost:8000/last)
  test "$result" = "$content2"

  # Test 404 when no files exist
  rm -r upload
  mkdir upload
  result=$(curl -s -o /dev/null -w "%{http_code}" localhost:8000/last)
  test "$result" = "404"
}

teardown() {
  rm -f file1.txt file2.txt
  rm -rf upload
}
