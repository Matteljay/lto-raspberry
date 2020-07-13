#!/bin/bash
set -e
cd "$(dirname "$0")"

exec /usr/bin/java -Xms256m -Xmx448m \
-Dlogback.stdout.level="INFO" \
-Dlto.directory="./chain" \
-Dlto.data-directory="./chain/data" \
-jar lto-public-all-arm.jar lto-mainnet.conf

# EOF
