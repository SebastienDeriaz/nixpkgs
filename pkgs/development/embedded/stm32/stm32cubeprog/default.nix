{ lib, stdenv, makeDesktopItem, copyDesktopItems, icoutils, fdupes, imagemagick, jdk11, fetchzip }:

# Heavily inspired by https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/development/embedded/stm32/stm32cubemx/default.nix

stdenv.mkDerivation rec {
  pname = "stm32cubeprog";
  version = "2.12.0";

  src = fetchzip {
    url = "https://www.st.com/content/ccc/resource/technical/software/utility/group0/2c/71/de/d9/d5/2f/4f/4c/stm32cubeprg-lin-v2-12-0/files/stm32cubeprg-lin-v2-12-0.zip/jcr:content/translations/en.stm32cubeprg-lin-v2-12-0.zip";
    #sha256 = "sha256-NfJMXHQ7JXzRSdOAYfx2t0xsi/w2S5FK3NovcsDOi+E=";
    stripRoot = false;
  };

  nativeBuildInputs = [ icoutils fdupes imagemagick copyDesktopItems ];
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

  buildCommand = let iconame = "STM32CubeProgrammer"; in
    ''
      mkdir -p $out/{bin,opt/STM32CubeProgrammer}
      cp -r $src/MX/. $out/opt/STM32CubeProgrammer/
      chmod +rx $out/opt/STM32CubeProgrammer/STM32CubeProgrammer
      cat << EOF > $out/bin/${pname}
      #!${stdenv.shell}
      ${jdk11}/bin/java -jar $out/opt/STM32CubeProgrammer/STM32CubeProgrammer
      EOF
      chmod +x $out/bin/${pname}
      icotool --extract $out/opt/STM32CubeProgrammer/help/${iconame}.ico
      fdupes -dN . > /dev/null
      ls
      for size in 16 24 32 48 64 128 256; do
        mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
        if [ $size -eq 256 ]; then
          mv ${iconame}_*_"$size"x"$size"x32.png \
            $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
        else
          convert -resize "$size"x"$size" ${iconame}_*_256x256x32.png \
            $out/share/icons/hicolor/"$size"x"$size"/apps/${pname}.png
        fi
      done;
    '';

  meta = with lib; {
    description = "A graphical tool for configuring STM32 microcontrollers and microprocessors";
    longDescription = ''
      A graphical tool that allows a very easy configuration of STM32
      microcontrollers and microprocessors, as well as the generation of the
      corresponding initialization C code for the Arm® Cortex®-M core or a
      partial Linux® Device Tree for Arm® Cortex®-A core), through a
      step-by-step process.
    '';
    homepage = "https://www.st.com/en/development-tools/stm32cubemx.html";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ SebastienDeriaz ];
    platforms = platforms.all;
  };
}

