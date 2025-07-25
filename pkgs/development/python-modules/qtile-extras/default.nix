{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  imagemagick,
  keyring,
  librsvg,
  pulseaudio,
  pytest-asyncio,
  pytest-lazy-fixture,
  pytest-rerunfailures,
  pytestCheckHook,
  python-dateutil,
  qtile,
  requests,
  setuptools-scm,
  xorgserver,
}:

buildPythonPackage rec {
  pname = "qtile-extras";
  version = "0.32.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "elParaguayo";
    repo = "qtile-extras";
    tag = "v${version}";
    hash = "sha256-NMbgSStXJV8fVtula1cyIwFlD8WrO8kBnOphDxbig04=";
  };

  build-system = [ setuptools-scm ];

  dependencies = [ gtk3 ];

  nativeCheckInputs = [
    gobject-introspection
    imagemagick
    keyring
    pulseaudio
    pytest-asyncio
    pytest-lazy-fixture
    pytest-rerunfailures
    pytestCheckHook
    python-dateutil
    qtile
    requests
    xorgserver
    # stravalib  # marked as broken due to https://github.com/stravalib/stravalib/issues/379
  ];

  disabledTests = [
    # Needs a running DBUS
    "test_brightness_power_saving"
    "test_global_menu"
    "test_mpris2_popup"
    "test_statusnotifier_menu"
    # No network connection
    "test_wifiicon_internet_check"
    # Image difference is outside tolerance
    "test_decoration_output"
    # Needs Github token
    "test_githubnotifications_reload_token"
    # AttributeError: 'NoneType' object has no attribute 'theta'
    "test_image_size_horizontal"
    "test_image_size_vertical"
    # flaky, timing sensitive
    "test_visualiser"
  ];

  disabledTestPaths = [
    # Needs a running DBUS
    "test/widget/test_iwd.py"
    "test/widget/test_upower.py"
    # Marked as broken due to https://github.com/stravalib/stravalib/issues/379
    "test/widget/test_strava.py"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export GDK_PIXBUF_MODULE_FILE=${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
    sed -i 's#/usr/bin/sleep#sleep#' test/widget/test_snapcast.py
  '';

  pythonImportsCheck = [ "qtile_extras" ];

  meta = with lib; {
    description = "Extra modules and widgets for the Qtile tiling window manager";
    homepage = "https://github.com/elParaguayo/qtile-extras";
    changelog = "https://github.com/elParaguayo/qtile-extras/blob/${src.tag}/CHANGELOG";
    license = licenses.mit;
    maintainers = with maintainers; [ arjan-s ];
  };
}
