{ config, lib, ... }:
let
  node = {  # tailscale internal IPs, this module conflicts with MagicDNS
    riverwood = "100.108.254.101";
    whiterun = "100.85.38.19";
  }."${config.networking.hostName}";

  mySubdomains = 
  let
    nginx = builtins.attrNames config.services.nginx.virtualHosts;
    baseDomain = "${config.networking.hostName}.${config.networking.domain}";
  in lib.flatten [ nginx baseDomain ];
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      port=53
      domain-needed
      bogus-priv
      no-resolv
      local=/${config.networking.domain}/
    '';
  };
  networking.hosts = {
    "${node}" = mySubdomains;
  };
}
