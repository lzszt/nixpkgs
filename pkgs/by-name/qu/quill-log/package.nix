{
  cmake,
  fetchFromGitHub,
  lib,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "quill-log";
  version = "9.0.2";

  src = fetchFromGitHub {
    owner = "odygrd";
    repo = "quill";
    rev = "v${version}";
    hash = "sha256-8BXdSITZKdJSstS4LbOCT9BedFHbmd/6bAPiQsCC+8Y=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    homepage = "https://github.com/odygrd/quill";
    changelog = "https://github.com/odygrd/quill/blob/master/CHANGELOG.md";
    downloadPage = "https://github.com/odygrd/quill";
    description = "Asynchronous Low Latency C++17 Logging Library";
    platforms = platforms.all;
    license = licenses.mit;
    maintainers = [ maintainers.odygrd ];
  };
}
