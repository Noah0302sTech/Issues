# Issues
## A Collection of all the Issues I've encountered while creating Bash-Scripts

### DevNull Segmentation-Fault
I encountered this Issue, when I was creating a Bash-Script to automatically install the Omada-Controller Software.
Using a Bash-Spinner Animation, which checks for Errors with ```bash COMMAND_HERE > /dev/null 2>&1``` and displays a Success- or Failure-Message, leads to ```Segmentation fault``` Message in the Shell.
This only happens if the Spinner-Delay is too low, meaning how fast the Loading-Animation is spinning, or the System executing the Command takes too long.
I was able to properly recreate this Issue with multiple Debian-11 VMs with differing CPU- and Disk-Speeds.
The lower the Spinner-Delay is, the sooner the Segmentation Fault will occur.
Depending on the speed of your System, it might only occur when the Delay is 0.01 or lower.
