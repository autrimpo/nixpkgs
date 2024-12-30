{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
}:

buildGoModule rec {
  pname = "any-sync-tools";
  version = "0.2.8";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-y582GwDPx9h6Zz+QGxZRXiB7pAHl7YxIi9nRl7Tpytk=";
  };

  vendorHash = "sha256-Kfq+EV8r2w4hi271Vw4DqsWP4dYcTse3/aQcYbU9TDQ=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "any-sync-netcheck"
    "any-sync-network"
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    mkdir $out/share
    cp any-sync-network/defaultTemplate.yml $out/share
    wrapProgram $out/bin/any-sync-network \
      --add-flags "--c $out/share/defaultTemplate.yml"
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-tools";
    description = "Configuration builder for Any-Sync nodes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-network";
  };
}
