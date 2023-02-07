{ lib, fetchPypi, buildPythonPackage, hatchling, pytestCheckHook }:

buildPythonPackage rec {
  pname = "sun-phy";
  version = "0.1.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "08695f5cb7ed6e0531a20572697297273c47b8cae5a63ffc6d6ed5c201be6e44";
  };

  nativeBuildInputs = [ hatchling ];

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "sun-phy" ];

  meta = with lib; {
    i
      description = "A Python implementation of 802.15.4g LR-WPANs SUN PHY";
    homepage = "https://github.com/SebastienDeriaz/sun_phy";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
  };
}
