# Create the directory which CircleCI will cache
mkdir ~/.node-js-cache

if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
    # No installation takes place here, nvm-windows should
    # already be installed on the machine image from CircleCI

    # Change where versions are installed so we can easily cache them
    nvm root ~/.node-js-cache;

    # Store the version so cache keys can easily use it
    nvm version > ~/.nvm-version;
else
    # Copyright (c) 2019 CircleCI Public
    # (derived from https://github.com/CircleCI-Public/node-orb/blob/master/src/scripts/install-nvm.sh)

    # Only install nvm if it's not already installed
    if command -v nvm &> /dev/null; then
        echo "nvm is already installed. Skipping nvm install.";
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash;

        echo 'export NVM_DIR="$HOME/.nvm"' >> "$BASH_ENV";
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use' >> "$BASH_ENV";

        # shellcheck source=/dev/null
        source "$BASH_ENV";
    fi

    # Store the version so cache keys can easily use it
    nvm -v > ~/.nvm-version;
fi
