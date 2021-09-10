#!/bin/bash
set -x

# clever logs -a monstage-replica--since $(date -v -10m +%FT%TZ)
clever logs -a monstage-replica
