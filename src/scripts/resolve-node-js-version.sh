set -eo pipefail

NODE_RELEASES="https://nodejs.org/download/release/index.json"
VERSION_KEY_REGEX="\"version\":\s*\"v[0-9]+\.[0-9]+\.[0-9]+\""
VERSION_NUMBER_REGEX="[0-9]+\.[0-9]+\.[0-9]+"

if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    # Windows has its own sort.exe, which we do not want
    SORT="/usr/bin/sort"
else
    SORT="sort"
fi

if [ -n "$NODE_PARAM_VERSION_FILE" ] && [ -n "$NODE_PARAM_VERSION" ]; then
    echo "Cannot provide both node-version and node-version-file";
    exit 1;
elif [ -n "$NODE_PARAM_VERSION_FILE" ]; then
    RESOLVED_VERSION=$(<"$NODE_PARAM_VERSION_FILE");
elif [ -n "$NODE_PARAM_VERSION" ]; then
    case $NODE_PARAM_VERSION in
      latest)
        RESOLVED_VERSION=$(curl -fs "$NODE_RELEASES" | grep -Eo "$VERSION_KEY_REGEX" - | grep -Eo "$VERSION_NUMBER_REGEX" | $SORT -V | tail -n1)
        ;;

      lts)
        RESOLVED_VERSION=$(curl -fs "$NODE_RELEASES" | tr -d '\n' | grep -Eo '"version":\s*"v[0-9]+\.[0-9]+\.[0-9]+",[^}]*"lts":\s*"' - | grep -Eo "$VERSION_KEY_REGEX" | grep -Eo "$VERSION_NUMBER_REGEX" | $SORT -V | tail -n1)
        ;;

      *)
        RESOLVED_VERSION=$(curl -fs "$NODE_RELEASES" | grep -Eo "\"version\":\s*\"v${NODE_PARAM_VERSION}(.[0-9]+)*\"" - | grep -Eo "$VERSION_NUMBER_REGEX" | $SORT -V | tail -n1)
        ;;
    esac
else
    echo "Must provide either node-version or node-version-file";
    exit 1;
fi

# Store the full version so cache keys can easily use it
echo "$RESOLVED_VERSION" > ~/.node-js-version;
