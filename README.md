# CurrentCostcc128_emoncms
Get data from cc128 electricity monitor over serial port, push to emoncms database.

The Current Cost cc128 device outputs data over serial port (RJ45 port but the signal is serial).

To run this program on an Rpi, first ensure /boot/cmdline.txt is edited to read as follows:

dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait

This prevents serial from sending commands to the terminal.  I believe this is now also possible to do through raspi-config.
It shoudl be in "advanced", "serial", "enable/disable shell and kernal messages on the serial connection".  
That should be set to "disable".

For the R Pi 3, it might be desirable to remap the 'good' UART to the GPIO (if you're not using bluetooth).
Do so by adding these two lines to /boot/config.txt

dtoverlay=pi3-miniuart-bt
enable_uart=1

Lastly, run the script by putting it in /usr/local/bin then adding this line to /etc/rc.local

su -c "/usr/local/bin/cc128_perl.pl start" pi &


