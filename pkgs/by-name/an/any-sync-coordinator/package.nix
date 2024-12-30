{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-coordinator";
  version = "0.4.4";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-JRiIM4UP92R+PI00XI6+yTIKaK1Q1pgkSp+6k9QWa+E=";
  };

  vendorHash = "sha256-6qzqeYaaU2IwTLabPMebRjnsXitKlcCAZoIWCs4mOds=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "cmd/coordinator"
    "cmd/confapply"
  ];

  postInstall = ''
    mv $out/bin/coordinator $out/bin/any-sync-coordinator
    mv $out/bin/confapply $out/bin/any-sync-confapply
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-coordinator";
    description = "Implementation of coordinator node from any-sync protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-coordinator";
  };
}
