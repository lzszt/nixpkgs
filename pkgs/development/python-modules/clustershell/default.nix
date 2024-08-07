{
  stdenv,
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  openssh,
  nose,
  bc,
  hostname,
  bash,
}:

buildPythonPackage rec {
  pname = "clustershell";
  version = "1.9.2";

  src = fetchPypi {
    pname = "ClusterShell";
    inherit version;
    hash = "sha256-rsF/HG4GNBC+N49b+sDO2AyUI1G44wJNBUwQNPzShD0=";
  };

  postPatch = ''
    substituteInPlace lib/ClusterShell/Worker/Ssh.py \
      --replace '"ssh"' '"${openssh}/bin/ssh"' \
      --replace '"scp"' '"${openssh}/bin/scp"'

    substituteInPlace lib/ClusterShell/Worker/fastsubprocess.py \
      --replace '"/bin/sh"' '"${bash}/bin/sh"'

    for f in tests/*; do
      substituteInPlace $f \
        --replace '/bin/hostname'   '${hostname}/bin/hostname' \
        --replace '/bin/sleep'      'sleep' \
        --replace '/bin/echo'       'echo' \
        --replace '/bin/uname'      'uname' \
        --replace '/bin/false'      'false' \
        --replace '/bin/true'       'true' \
        --replace '/usr/bin/printf' 'printf'
    done

    # Fix warnings
    substituteInPlace lib/ClusterShell/Task.py \
      --replace "notifyAll" "notify_all"
    substituteInPlace tests/TaskPortTest.py lib/ClusterShell/Task.py \
      --replace "currentThread" "current_thread"
  '';

  propagatedBuildInputs = [ pyyaml ];

  nativeCheckInputs = [
    bc
    hostname
    nose
  ];

  pythonImportsCheck = [ "ClusterShell" ];

  doCheck = false; # tests often get stuck

  # Many tests want to open network connections
  # https://github.com/cea-hpc/clustershell#test-suite
  #
  # Several tests fail on Darwin
  checkPhase = ''
    rm tests/CLIClushTest.py
    rm tests/TreeWorkerTest.py
    rm tests/TaskDistantMixin.py
    rm tests/TaskDistantTest.py
    rm tests/TaskDistantPdshMixin.py
    rm tests/TaskDistantPdshTest.py
    rm tests/TaskRLimitsTest.py
    rm tests/TreeGatewayTest.py

    nosetests -v \
      -e test_fromall_grouplist \
      -e test_rank_placeholder \
      -e test_engine_on_the_fly_launch \
      -e test_ev_pickup_fanout \
      -e test_ev_pickup_fanout_legacy \
      -e test_timeout \
      -e test_008_broken_pipe_on_write \
      -e testLocalBufferRCGathering \
      -e testLocalBuffers \
      -e testLocalErrorBuffers \
      -e testLocalFanout \
      -e testLocalRetcodes \
      -e testLocalRCBufferGathering \
      -e testLocalSingleLineBuffers \
      -e testLocalWorkerFanout \
      -e testSimpleMultipleCommands \
      -e testClushConfigSetRlimit  \
      -e testTimerInvalidateInHandler \
      -e testTimerSetNextFireInHandler \
      -e test_node_placeholder \
    tests/*.py
  '';

  meta = with lib; {
    broken = stdenv.isDarwin;
    description = "Scalable Python framework for cluster administration";
    homepage = "https://cea-hpc.github.io/clustershell";
    license = licenses.lgpl21;
    maintainers = [ maintainers.alexvorobiev ];
  };
}
