{ config, pkgs, lib, agenix, private, ... }:
let
  sendTg = pkgs.writeShellScript "send-tg" ''
    TG_BOT_TOKEN=$(cat ${config.age.secrets."tg_bot_key".path})
    TG_BOT_CHAT_ID=$(cat ${config.age.secrets."tg_bot_chat_id".path})

    # Parse flags
    SILENT=false
    while getopts "s" opt; do
      case $opt in
        s) SILENT=true ;;
        *) echo "Usage: $0 [-s] <message>" >&2; exit 1 ;;
      esac
    done
    shift $((OPTIND-1))

    # Properly escape the message for JSON
    MESSAGE=$(${pkgs.jq}/bin/jq -n --arg text "$1" '$text')

    if ${pkgs.curl}/bin/curl -s -f -H 'Content-Type: application/json' \
       -d "{\"chat_id\": \"$TG_BOT_CHAT_ID\", \"text\": $MESSAGE, \"disable_notification\": $SILENT, \"parse_mode\": \"MarkdownV2\"}" \
      "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" > /dev/null 2>&1; then
      exit 0
    fi

    echo "Failed to send Telegram message after $MAX_RETRIES attempts" >&2
    exit 1
  '';
in {
  imports = [ agenix.nixosModules.default ];

  options.server_base.telegram-notify = {
    script = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      default = sendTg;
      description = "Path to the Telegram notification script";
    };
  };

  config = {
    age.secrets = {
      "tg_bot_key" = {
        file = private.secretPath { name = "tg_bot_key"; };
        mode = "0400";
        owner = "root";
        group = "root";
      };
      "tg_bot_chat_id" = {
        file = private.secretPath { name = "tg_bot_chat_id"; };
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };
}
