{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-node";
  version = "0.4.13";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-eGosxpRA6CYUY5yUJdvgwqMJTyTSjsSYqi0KxfFnYLw=";
  };

  vendorHash = "sha256-U+R0VW3IAhIXGsrPml1EH5m95I7TWJL5IwAkU+8JPUk=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "cmd"
  ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/any-sync-node
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-node";
    description = "Implementation of node from any-sync protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-node";
  };
}
