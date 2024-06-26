# These are the default options CircleCI uses, but they may
# not be set if we're running under Rosetta, so set them now
set -eo pipefail

if [ -n "$NODE_PARAM_VERSION_FILE" ] && [ -n "$NODE_PARAM_VERSION" ]; then
    echo "Cannot provide both node-version and node-version-file";
    exit 1;
fi

# Similarly, nvm may not be set up under a Rosetta terminal
if [[ "$OSTYPE" == "darwin"* ]]; then
    # shellcheck disable=SC1091
    source "${NVM_DIR}/nvm.sh" --no-use;
fi

if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    # See: https://github.com/coreybutler/nvm-windows#usage
    if [ -n "$NODE_PARAM_VERSION" ]; then
        # nvm-windows supports "latest" and "lts" as possible values
        nvm install "$NODE_PARAM_VERSION";
    elif [ -n "$NODE_PARAM_VERSION_FILE" ] && [ -f "$NODE_PARAM_VERSION_FILE" ]; then
        NODE_PARAM_VERSION=$(<"$NODE_PARAM_VERSION_FILE");
        nvm install "$NODE_PARAM_VERSION";
    else
        echo "Must provide either node-version or node-version-file";
        exit 1;
    fi

    nvm use newest;
    echo 'nvm use newest &>/dev/null' >> "$BASH_ENV";

    # Confirm that the Node.js version matches what is expected
    # using the fully resolved version number from the other
    # script, 'resolve-node-js-version.sh'. This is necessary
    # because nvm-windows will silently fail if there's an error
    # while downloading (and Node.js servers are unstable lately)
    # See: https://github.com/coreybutler/nvm-windows/issues/738
    if [ "$(node -v)" != "v$(cat ~/.node-js-version)" ]; then
        exit 1;
    fi
else
    # Copyright (c) 2019 CircleCI Public
    # (derived from https://github.com/CircleCI-Public/node-orb/blob/master/src/scripts/install-nvm.sh)
    # See: https://github.com/nvm-sh/nvm#usage
    if [ "$NODE_PARAM_VERSION" = "latest" ]; then
        # When no version is specified we default to the latest version of Node
        NODE_ORB_INSTALL_VERSION=$(nvm ls-remote | tail -n1 | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+');
        nvm install -b "$NODE_ORB_INSTALL_VERSION"; # aka nvm install node. We're being explicit here.
        nvm alias default "$NODE_ORB_INSTALL_VERSION";
    elif [ "$NODE_PARAM_VERSION" = "lts" ]; then
        nvm install -b --default --lts;
        nvm alias default lts/*;
    elif [ -n "$NODE_PARAM_VERSION" ]; then
        nvm install -b "$NODE_PARAM_VERSION";
        nvm alias default "$NODE_PARAM_VERSION";
    elif [ -n "$NODE_PARAM_VERSION_FILE" ] && [ -f "$NODE_PARAM_VERSION_FILE" ]; then
        NODE_PARAM_VERSION=$(<"$NODE_PARAM_VERSION_FILE");
        nvm install -b "$NODE_PARAM_VERSION";
        nvm alias default "$NODE_PARAM_VERSION";
    else
        echo "Must provide either node-version or node-version-file";
        exit 1;
    fi

    echo 'nvm use default &>/dev/null' >> "$BASH_ENV";
fi
