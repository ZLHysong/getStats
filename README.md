# getStats (A small collection of analytic utilities)

This collection of files exists to help gather analytic data from a docker droplet.

## Process

Install the files with:

1. `wget https://raw.githubusercontent.com/ZLHysong/getStats/master/install.sh`
1. `chmod +x ./install.sh`
1. `sudo ./install.sh`

This will download the install script, make it executable, then run it as root. This is important as it potentially installs at least one package, and changes some permissions for `vnstat` during configuration.

Once it is installed, it will automatically gather data every 15 minutes, and place that data in `log.txt` of the install directory. (The install directory can be changed in `./install.sh` before running it.)

Then, once a week, it takes all the data from log.txt, backs it up to log[currentdate].txt, and runs additional analytics on it, which it places in a "final" report, which is user accessible.