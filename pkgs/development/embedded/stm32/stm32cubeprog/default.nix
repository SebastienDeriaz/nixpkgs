{ config, lib, stdenv, makeDesktopItem, copyDesktopItems, icoutils, fdupes, imagemagick, jdk11, fetchzip, xdotool, xvfb-run, xeyes, pkgs ? import <nixpkgs> {}}:

# Heavily inspired by https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/development/embedded/stm32/stm32cubemx/default.nix
# https://github.com/SebastienDeriaz
# 25.12.2022

stdenv.mkDerivation rec {
  pname = "stm32cubeprog";
  version = "2.12.0";
  xdotool_script = ./stm32cubeprog.xdotool;


  src = fetchzip {
    url = "https://www.st.com/content/ccc/resource/technical/software/utility/group0/2c/71/de/d9/d5/2f/4f/4c/stm32cubeprg-lin-v2-12-0/files/stm32cubeprg-lin-v2-12-0.zip/jcr:content/translations/en.stm32cubeprg-lin-v2-12-0.zip";
    sha256 = "sha256-iS0dhrwCWBG2oOcYLgPosXuHCLOx1AIhQPXp4N2C/xI=";
    stripRoot = false;
  };

  nativeBuildInputs = [ icoutils fdupes imagemagick copyDesktopItems xdotool xvfb-run xeyes];
  desktopItems = [
    (makeDesktopItem {
      name = "stm32CubeProgrammer";
      exec = "STM32_Programmer_CLI";
      desktopName = "STM32CubeProgrammer";
      categories = [ "Development" ];
      comment = "STM32CubeProgrammer software for all STM32";
      icon = "stm32cubeprog";
    })
  ]; 

  buildCommand = let
    iconame = "STM32CubeProgrammer";
      
    in
    ''
      echo A
      mkdir -p $out

      cat << EOF > $out/stm32cubeprog.xvfb

      ${jdk11}/bin/java -jar $out/SetupSTM32CubeProgrammer-2.12.0.exe & 

      xdotool ${xdotool_script} $out/build
      EOF

      #cp --no-preserve=mode,ownership $src/* $out -r
      cp $src/* $out -r
      chmod +x $out/SetupSTM32CubeProgrammer-2.12.0.linux $out/stm32cubeprog.xvfb

      echo "$out : "
      ls $out -la

      mkdir $out/build

      #xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" -w 5 $out/stm32cubeprog.xvfb
      #xvfb-run --server-args="-screen 0 1920x1080x24" --auto-servernum --print-errorlogs -w 5 $out/stm32cubeprog.xvfb
      xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" $out/stm32cubeprog.xvfb

      #export DISPLAY=:0.0
      #ls $out -la
      #exec $out/SetupSTM32CubeProgrammer-2.12.0.linux &

      #import -window root A.png

      #xdotool ${xdotool_script} $out

      mkdir $out/screenshots
      touch empty.png
      cp *.png $out/screenshots

      cp $out/build/* $out -r

      
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

