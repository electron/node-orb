# Skip with nvm-windows, we already changed the root dir, so no sense
# in trying to parse the not very machine friendly output of `nvm root`
if [[ "$OSTYPE" != "cygwin" && "$OSTYPE" != "msys" ]]; then
    cp -r ~/.node-js-cache/. "$(nvm cache dir)";
fi
