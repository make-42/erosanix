{
  lib,
  mkWindowsAppNoCC,
  wine,
  fetchurl,
  makeDesktopItem,
  makeDesktopIcon,
  copyDesktopItems,
  copyDesktopIcons,
}: let
in
  mkWindowsAppNoCC rec {
    inherit wine;

    pname = "micro-manager";
    release = "2.0";
    version = "${release}.0";

    src = fetchurl {
      url = "https://download.micro-manager.org/release/${release}/Windows/MMSetup_64bit_${version}.exe";
      hash = "sha256-d07J/khPNndq3Mu0MFX4fMZlEoxxyLlPnUrQlyR0l9c=";
    };

    dontUnpack = true;
    wineArch = "win64";
    persistRegistry = true;
    nativeBuildInputs = [copyDesktopItems copyDesktopIcons];

    fileMap = {
      "$HOME/.cache/micro-manager/Local Settings" = "drive_c/users/$USER/Local Settings";
      "$HOME/.cache/micro-manager/AppData" = "drive_c/users/$USER/AppData";
    };

    enabledWineSymlinks = {
      desktop = false;
    };

    winAppInstall = ''
      $WINE ${src}
      wineserver -w
    '';

    winAppPreRun = ''
    '';

    winAppRun = ''
      $WINE "$WINEPREFIX/drive_c/Program Files/Micro-Manager-${release}/micromanager.exe"
    '';

    installPhase = ''
      runHook preInstall

      ln -s $out/bin/.launcher $out/bin/micro-manager

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = pname;
        exec = pname;
        icon = pname;
        desktopName = "Micro-Manager";
        categories = ["Science"];
      })
    ];

    desktopIcon = makeDesktopIcon {
      name = "micro-manager";

      src = fetchurl {
        url = "https://micro-manager.org/media/logo/logo-web.png";
        sha256 = "sha256-mWQ4zcPLPiv5et5qEDdVd2wKPETS4KmXb/7p/0hpNUA==";
      };
    };

    meta = with lib; {
      description = "Micro-Manager";
      homepage = "https://micro-manager.org";
      license = licenses.bsd3;
      maintainers = with maintainers; [];
      platforms = ["x86_64-linux"];
    };
  }
