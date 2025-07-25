{
  lib,
  fetchurl,
  intltool,
  libtorrent-rasterbar,
  python3Packages,
  gtk3,
  glib,
  gobject-introspection,
  librsvg,
  wrapGAppsHook3,
  nixosTests,
}:

let
  inherit (lib) optionals;

  pypkgs = python3Packages;

  generic =
    { pname, withGUI }:
    pypkgs.buildPythonPackage rec {
      inherit pname;
      version = "2.2.0";
      format = "setuptools";

      src = fetchurl {
        url = "http://download.deluge-torrent.org/source/${lib.versions.majorMinor version}/deluge-${version}.tar.xz";
        hash = "sha256-ubonK1ukKq8caU5sKWKKuBbMGnAKN7rAiqy1JXFgas0=";
      };

      propagatedBuildInputs =
        with pypkgs;
        [
          twisted
          mako
          chardet
          pyxdg
          pyopenssl
          service-identity
          libtorrent-rasterbar.dev
          libtorrent-rasterbar.python
          setuptools
          setproctitle
          pillow
          rencode
          six
          zope-interface
          dbus-python
          pycairo
          librsvg
        ]
        ++ optionals withGUI [
          gtk3
          gobject-introspection
          pygobject3
        ];

      nativeBuildInputs = [
        intltool
        glib
      ]
      ++ optionals withGUI [
        gobject-introspection
        wrapGAppsHook3
      ];

      nativeCheckInputs = with pypkgs; [
        pytestCheckHook
        pytest-twisted
        pytest-cov-stub
        mock
        mccabe
        pylint
      ];

      doCheck = false; # tests are not working at all

      postInstall = ''
        install -Dm444 -t $out/lib/systemd/system packaging/systemd/*.service
      ''
      + (
        if withGUI then
          ''
            mkdir -p $out/share
            cp -R deluge/ui/data/{icons,pixmaps} $out/share/
            install -Dm444 -t $out/share/applications deluge/ui/data/share/applications/deluge.desktop
          ''
        else
          ''
            rm -r $out/bin/deluge-gtk
            rm -r $out/${python3Packages.python.sitePackages}/deluge/ui/gtk3
            rm -r $out/share/{icons,man/man1/deluge-gtk*,pixmaps}
          ''
      );

      postFixup = ''
        for f in $out/lib/systemd/system/*; do
          substituteInPlace $f --replace /usr/bin $out/bin
        done
      '';

      passthru.tests = { inherit (nixosTests) deluge; };

      meta = with lib; {
        description = "Torrent client";
        homepage = "https://deluge-torrent.org";
        license = licenses.gpl3Plus;
        maintainers = with maintainers; [
          ebzzry
        ];
        platforms = platforms.all;
      };
    };

in
rec {
  deluge-gtk = generic {
    pname = "deluge-gtk";
    withGUI = true;
  };
  deluged = generic {
    pname = "deluged";
    withGUI = false;
  };
  deluge = deluge-gtk;
}
