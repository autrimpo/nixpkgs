{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "any-sync-filenode";
  version = "0.8.5";
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-h4e7T2Hiok3f9zUr8pPW8SrtOzmAzLD0j+xL6rqzyF4=";
  };

  vendorHash = "sha256-4S8fZgDI9i5+qDx/ciNi25X/CeNrA9RNZK0vnRq0KxI=";

  env.CGO_ENABLED = "1";

  subPackages = [
    "cmd"
  ];

  # tests try to connect to consensus node on localhost
  doCheck = false;

  postInstall = ''
    mv $out/bin/cmd $out/bin/any-sync-filenode
  '';

  meta = {
    homepage = "https://github.com/anyproto/any-sync-filenode";
    description = "Implementation of file node from any-sync protocol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "any-sync-filenode";
  };
}
