{ lib, stdenv, makeDesktopItem, copyDesktopItems, icoutils, fdupes, imagemagick, jdk11, fetchzip, xdotool, pkgs ? import <nixpkgs> {}}:

# Heavily inspired by https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/development/embedded/stm32/stm32cubemx/default.nix

stdenv.mkDerivation rec {
  pname = "stm32cubeprog";
  version = "2.12.0";
  xdotool_script = ./stm32cubeprog.xdotool;
  xvfb_script    = ./stm32cubeprog.xvfb

  #nodes.machine = { pkgs, ... }: {                                            
  #  environment.systemPackages = [ pkgs.hello ];
  #};

  src = fetchzip {
    url = "https://www.st.com/content/ccc/resource/technical/software/utility/group0/2c/71/de/d9/d5/2f/4f/4c/stm32cubeprg-lin-v2-12-0/files/stm32cubeprg-lin-v2-12-0.zip/jcr:content/translations/en.stm32cubeprg-lin-v2-12-0.zip";
    sha256 = "sha256-iS0dhrwCWBG2oOcYLgPosXuHCLOx1AIhQPXp4N2C/xI=";
    stripRoot = false;
  };

  nativeBuildInputs = [ icoutils fdupes imagemagick copyDesktopItems xdotool];
  desktopItems = [
    (makeDesktopItem {
      name = "stm32CubeProgrammer";
      exec = "stm32cubeProgrammer";
      desktopName = "STM32CubeProgrammer";
      categories = [ "Development" ];
      comment = "STM32CubeProgrammer software for all STM32";
      icon = "stm32cubeprog";
    })
  ];

  #machine.console.keyMap = mkOverride 900 layout;
  #machine.services.xserver.desktopManager.xterm.enable = false;
  #machine.services.xserver.layout = mkOverride 900 layout;
  #machine.imports = [ ./common/x11.nix ];

  

  buildCommand = let
    iconame = "STM32CubeProgrammer";
      
    in
    ''
      ls $src -la
      # Start the linux installer
      echo $src/SetupSTM32CubeProgrammer-2.12.0.linux
      $src/SetupSTM32CubeProgrammer-2.12.0.linux &

      export DISPLAY=:0
      # specify $srcdir/build as temporary dir
      echo "Running xdotool"
      echo "Saving in " $out

      # xdotool ${xdotool_script} $out
      xdotool --help # key --delay 100 p r e f e r e n c e s

      echo "A"

      mkdir -p $out/bin
      touch $out/bin/test

      echo "B"

      # ls $out -la

      echo "C"
      
      # mkdir -p $out/{bin,opt/STM32CubeProgrammer}
      # cp -r $src/MX/. $out/opt/STM32CubeProgrammer/
      # chmod +rx $out/opt/STM32CubeProgrammer/STM32CubeProgrammer
      # cat << EOF > $out/bin/${pname}
      # #!${stdenv.shell}
      # ${jdk11}/bin/java -jar $out/opt/STM32CubeProgrammer/STM32CubeProgrammer
      # EOF
      # chmod +x $out/bin/${pname}
      # icotool --extract $out/opt/STM32CubeProgrammer/help/${iconame}.ico
      # fdupes -dN . > /dev/null
      # ls
      # for size in 16 24 32 48 64 128 256; do
      #   mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
      #   if [ $size -eq 256 ]; then
      #     mv ${iconame}_*_"$size"x"$size"x32.png \
      #       $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
      #   else
      #     convert -resize "$size"x"$size" ${iconame}_*_256x256x32.png \
      #       $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
      #   fi
      # done;
    '';

  meta = with lib; {
    description = "An all-in-one software tool for programming STM32 products";
    longDescription = ''
      An easy-to-use and efficient environment for reading, writing and verifying
      device memory through both the debug interface (JTAG and SWD) and
      the bootloader interface (UART, USB DFU, I2C, SPI, and CAN).
      STM32CubeProgrammer offers a wide range of features to program
      STM32 internal memories (such as Flash, RAM, and OTP) as well as external memories.
      STM32CubeProgrammer also allows option programming and upload,
      programming content verification, and programming automation through scripting.
    '';
    homepage = "https://www.st.com/en/development-tools/stm32cubeprog.html";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ SebastienDeriaz ];
    platforms = platforms.all;
  };
}

