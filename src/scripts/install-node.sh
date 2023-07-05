if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    # See: https://github.com/coreybutler/nvm-windows#usage
    if [ -n "$NODE_PARAM_VERSION" ]; then
        # nvm-windows supports "latest" and "lts" as possible values
        nvm install "$NODE_PARAM_VERSION";
    elif [ -f ".nvmrc" ]; then
        NVMRC_SPECIFIED_VERSION=$(<.nvmrc);
        nvm install "$NVMRC_SPECIFIED_VERSION";
    else
        nvm install lts;
    fi

    echo 'nvm use newest &>/dev/null' >> "$BASH_ENV";
else
    # Copyright (c) 2019 CircleCI Public
    # (derived from https://github.com/CircleCI-Public/node-orb/blob/master/src/scripts/install-nvm.sh)
    # See: https://github.com/nvm-sh/nvm#usage
    if [ "$NODE_PARAM_VERSION" = "latest" ]; then
        # When no version is specified we default to the latest version of Node
        NODE_ORB_INSTALL_VERSION=$(nvm ls-remote | tail -n1 | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+');
        nvm install -b "$NODE_ORB_INSTALL_VERSION"; # aka nvm install node. We're being explicit here.
        nvm alias default "$NODE_ORB_INSTALL_VERSION";
    elif [ -n "$NODE_PARAM_VERSION" ] && [ "$NODE_PARAM_VERSION" != "lts" ]; then
        nvm install -b "$NODE_PARAM_VERSION";
        nvm alias default "$NODE_PARAM_VERSION";
    elif [ -f ".nvmrc" ]; then
        NVMRC_SPECIFIED_VERSION=$(<.nvmrc);
        nvm install -b "$NVMRC_SPECIFIED_VERSION";
        nvm alias default "$NVMRC_SPECIFIED_VERSION";
    else
        nvm install -b --default --lts;
        nvm alias default lts/*;
    fi

    echo 'nvm use default &>/dev/null' >> "$BASH_ENV";
fi
