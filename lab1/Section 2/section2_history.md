    1  git
    2  git clone --recurse-submodules https://github.com/evacree/cvw
    3  cd cvw
    4  source ./setup.sh
    5  echo $WALLY$
    6  cd examples/C/hello
    7  ls
    8  make
    9  wsim --sim questa rv64gc --elf hello

To set up our environment, we followed the steps outlined in the lab report and
cloned the /cvw repository to our system. We ran source ./setup.sh, and confirmed
with echo $WALLY$. We were then able to simulate hello.c using Questa. No issues were
encountered along the way.