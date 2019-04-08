#!/bin/bash
mkdir bin
bundle install --path=. --binstubs=bin
bin/rake chef:build
berks install
echo "If everything looks good, you can run `berks upload poise-python` now"
