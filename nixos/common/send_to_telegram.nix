{ config, pkgs, agenix, private, ... }: {
  imports = [ agenix.nixosModules.default ];
  age.secrets = {
    "tg_bot_key".file = private.secretPath { name = "tg_bot_key"; };
    "tg_bot_chat_id".file = private.secretPath { name = "tg_bot_chat_id"; };
  };
  util.sendTg = pkgs.writeShellScript "send-tg" ''
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

    ${pkgs.curl}/bin/curl -s -f -H 'Content-Type: application/json' \
       -d "{\"chat_id\": \"$''${TG_BOT_CHAT_ID}\", \"text\": $MESSAGE, \"disable_notification\": $SILENT}" \
      "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" || {
        echo "Failed to send Telegram message" >&2
        exit 1
      }
  '';
}
