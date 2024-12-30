{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-consensusnode";
  version = "0.2.2";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-N+v/uiwYoGBd1jcT5IK+mKQ1TmLeUSaR5YmJedI3hkw=";
  };

  vendorHash = "sha256-GHJdwSI1tG33BUHqG51g0TflflLVnptLaJ5wh/tr00k=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "cmd"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/any-sync-consensusnode
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-consensusnode";
    description = "Implementation of consensus node from any-sync protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-consensusnode";
  };
}
