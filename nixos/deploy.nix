let
  nodes = [ "operator" "ivan" ];
  deploy_options = node: {
    user = "deployer";
    host = node;
    cleanup = false;
    update_inputs = [ "private-part" ];
  };
in {
  nodes = builtins.listToAttrs (map (node: {
    name = node;
    value = deploy_options node;
  }) nodes);
}
