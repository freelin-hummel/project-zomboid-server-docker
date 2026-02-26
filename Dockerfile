FROM steamcmd/steamcmd:latest

# Install runtime tooling for consolidated init pipeline:
# - python3: resolver/download/cleanup scripts
# - lua5.4 : Lua-native conflict/order checks
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends python3 lua5.4 \
 && rm -rf /var/lib/apt/lists/*
