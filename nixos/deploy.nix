let
  nodes = [ "operator" "ivan" ];
  deploy_options = {
    user = "deployer";
    host = "operator";
    cleanup = false;
    update_inputs = [ "private-part" ];
  };
in builtins.listToAttrs (map (node: {
  name = node;
  value = deploy_options;
}) nodes)
