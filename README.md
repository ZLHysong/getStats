# This collection of files exists to help gather analytic data from a docker droplet.

## Process

> This install script depends on git being installed, so if it isn't, run `yum / apt install git -y` first.

Install the files with:

1. `cd ~`
1. `git clone https://github.com/ZLHysong/getStats.git && cd getStats`
1. `chmod +x ./install.sh`
    - This shouldn't actually be needed, as the git repo keeps executable permissions, but it's not a bad idea to run it anyways.
1. `sudo ./install.sh`

This will download the install script, make it executable, then run it as root. This is important as it potentially installs at least one package, and changes some permissions for `vnstat` during configuration.

Once it is installed, it will automatically gather data every 15 minutes, and place that data in `log.txt` of the install directory. (The install directory can be changed in `./install.sh` before running it.)

Then, once a week, it takes all the data from log.txt, backs it up to log[currentdate].txt, and runs additional analytics on it, which it places in a "final" report, which is user accessible.