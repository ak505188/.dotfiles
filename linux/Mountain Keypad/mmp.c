/* File 'mmp.c':
   Translate proprietary M1-M12 keys on the Mountain MacroPad to generic F13-F24 keys, respecting keypress and keyrelease events.
   Supports a custom config file 'mmp.cfg' for any custom system calls instead of xdotool-F-keys.
   Each line of the config file must not exceed 2048 bytes.

   Requires xdotool to be installed for using default settings.
   Requires udevadm.
   Requires read/write access in /tmp/.
   Requires read access to /dev/usb/hiddev* devices, so we must be run as root.
   You need to add the udev rules as written below, especially to create the 'mmpkeyboard' symlink.

   Compile with:   gcc mmp.c -o mmp
   and run with:   sudo ./mmp

   Optional command-line parameters:

    -h
        Help. Display all command-line options and most of this comment text here and terminate.

    -c  <filename>
        Specify config file instead of using default (mmp.cfg in current working directory).
        Filename must not exceed 1024 bytes.

    -k
        Instead of translating keydown+keyup events, just perform a single keypress event on keydown.
        Use this especially if anything should bug out/hang/freeze your keyboard.
        Example usage:  sudo ./mmp -k

    -d
        Just a debug run? With printf outputs but without actually calling xdotool to press/release any keys.
        Example usage:  sudo ./mmp -d

    -t  <number of attempts>
        Tries to find the pad on USB on startup, default is 15. Specify 0 for infinite retries.
        There is a 1 second delay after each try.

    -q
        Quiet operation: No text log output (stdout) for key events.

    Also, unbind the macropad as a keyboard to disable the predefined M1-key macro, and define it as 'mmpkeyboard' symlink:
    Run 'lsusb' to check vendor+device IDs:
     Bus 003 Device 006: ID 3282:0008 Mountain MOUNTAIN MacroPad

    and add a file
     /etc/udev/rules.d/99-mountainmacropad.rules
    with content:

     SUBSYSTEM=="input", ACTION=="add", ATTRS{idVendor}=="3282", ATTRS{idProduct}=="0008", RUN+="/bin/sh -c 'echo remove > /sys$env{DEVPATH}/uevent'"
     ACTION=="add", ATTRS{idVendor}=="3282", ATTRS{idProduct}=="0008", SYMLINK+="mmpkeyboard"

    and reboot (or reload udev rules, but rebooting is safest+easiest).

   Using this command on all devices in /dev/usb/ will tell you if it's really hiddev0 or some other device:
    udevadm info --query=symlink -n /dev/usb/hiddevN
   where you use N=0 and work your way through them until you find the "mmpkeyboard" symlink we defined in the udev rules for the macropad.
*/


#include <stdio.h>	// for fopen(), fread(). fclose(), FILE, printf(), sprintf()
#include <unistd.h>	// for STDIN_FILENO constant, optionally for sleep()
#include <string.h>	// for strcmp()
#include <stdlib.h>	// for system()
#include <dirent.h>	// for opendir(), readdir(), closedir(), dirent

#define EVSIZE 512

/* Events:
    On keypress, and keyrelease, 512 Bytes are sent from the hardware over USB (/dev/usb/hiddev0).

   Line pattern, variables indicated as '$n', in hex:
   02 00 00 ff  $1 00 00 00  02 00 00 ff  $2 00 00 00
   this line of 16 bytes is repeated 32 times,
   Lines are numbered #0 to #31 here, decimally.

   On keypress or keyrelease, the same kind of 512B event is fired:
    $1 and $2 are usually 00, except:
    line #00: $1 is 01.
    line #21: $1 is a mask consisting of the state of the first 7 M-keys (M1-M7):
     M1 +2, M2 +4, M3 +8, M4 +10, M5 +20, M6 +40, M7 +80 (hex)
    line #23: $2 is a mask consisting of the state of the last 5 M-keys (M8-M12):
     M8 +1, M9 +2, M10 +4, M11 +8, M12 +10 (hex)
    (If no matching keys are pressed, $1 and $2 respectively are 00, obviously.)
*/

#define SYSCALLLEN 80
#define CFG_LINE 2048

int main(int argc, char **argv) {
    char syscall[SYSCALLLEN], hiddev[40] = { 0 };

    /*                                   02    00    00    ff     $1    00    00    00     02    00    00    ff    $2    00    00    00 */
    unsigned char mkey0[16]        = { 0x02, 0x00, 0x00, 0xff,  0x01, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00 };
    unsigned char mkeyN[16]        = { 0x02, 0x00, 0x00, 0xff,  0x00, 0x00, 0x00, 0x00,  0x02, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00 };

    unsigned char usb_byte, buf[EVSIZE + 1] = { 0 }, mask1, mask2, mask1_prev = 0, mask2_prev = 0;
    int n, m, bit, bitmask;

    int f_dryrun = 0, f_keypress = 0, quiet = 0, usbhiddev_tries;

    char macrokey_syscall[3 * 12][CFG_LINE], cfg_tmp[CFG_LINE], cfg_file[1024];

    FILE *fp;
    DIR *dp;
    struct dirent *ep;


    printf("POSIX Mountain MacroPad driver v1.3 (by millus, 2024-06-29)\n");

    /* Evaluate optional command-line parameters */
    strcpy(cfg_file, "mmp.cfg");
    usbhiddev_tries = 15;

    for (n = 0; n < argc; n++) {
        if (!strcmp(argv[n], "-k")) {
            printf("Using singular keypress events instead of keyup/keydown.\n");
            f_keypress = 1;
        }
        if (!strcmp(argv[n], "-d")) {
            printf("Running in dry-run mode, not generating actual key events.\n");
            f_dryrun = 1;
        }
        if (!strcmp(argv[n], "-c")) {
            n++;
            if (n == argc || !argv[n][0]) {
                printf("Error: Missing config file name after '-c'.\n");
                return(-4);
            }
            strcpy(cfg_file, argv[n]);
        }
        if (!strcmp(argv[n], "-t")) {
            n++;
            if (n == argc || !argv[n][0]) {
                printf("Error: Missing amount of tries after '-t'.\n");
                return(-5);
            }
            if (atoi(argv[n]) < 0) {
                printf("Error: Number of tries must be positive (0 for 'infinite').\n");
                return(-6);
            }
            usbhiddev_tries = atoi(argv[n]);
        }
        if (!strcmp(argv[n], "-q")) quiet = 1;
        if (!strcmp(argv[n], "-h") || !strcmp(argv[n], "--help")) {
printf("\n"
"   Translate proprietary M1-M12 keys on the Mountain MacroPad to generic F13-F24 keys, respecting keypress and keyrelease events.\n"
"   Supports a custom config file 'mmp.cfg' for any custom system calls instead of xdotool-F-keys.\n"
"   Each line of the config file must not exceed 2048 bytes.\n"
"\n"
"   Requires xdotool to be installed for using default settings.\n"
"   Requires udevadm.\n"
"   Requires read/write access in /tmp/.\n"
"   Requires read access to /dev/usb/hiddev* devices, so we must be run as root.\n"
"   You need to add the udev rules as written below, especially to create the 'mmpkeyboard' symlink.\n"
"\n"
"   Optional command-line parameters:\n"
"\n"
"    -h\n"
"        Display this help text and terminate.\n"
"\n"
"    -c  <filename>\n"
"        Specify config file instead of using default (mmp.cfg in current working directory).\n"
"        Filename must not exceed 1024 bytes.\n"
"\n"
"    -k\n"
"        Instead of translating keydown+keyup events, just perform a single keypress event on keydown.\n"
"        Use this especially if anything should bug out/hang/freeze your keyboard.\n"
"        Example usage:  sudo ./mmp -k\n"
"\n"
"    -d\n"
"        Just a debug run? With printf outputs but without actually calling xdotool to press/release any keys.\n"
"        Example usage:  sudo ./mmp -d\n"
"\n"
"    -t  <number of attempts>\n"
"        Tries to find the pad on USB on startup, default is 15. Specify 0 for infinite retries.\n"
"        There is a 1 second delay after each try.\n"
"\n"
"    -q\n"
"        Quiet operation: No text log output (stdout) for key events.\n"
"\n"
"    Also, unbind the macropad as a keyboard to disable the predefined M1-key macro, and define it as 'mmpkeyboard' symlink:\n"
"    Run 'lsusb' to check vendor+device IDs:\n"
"     Bus 003 Device 006: ID 3282:0008 Mountain MOUNTAIN MacroPad\n"
"\n"
"    and add a file\n"
"     /etc/udev/rules.d/99-mountainmacropad.rules\n"
"    with content:\n"
"\n"
"     SUBSYSTEM==\"input\", ACTION==\"add\", ATTRS{idVendor}==\"3282\", ATTRS{idProduct}==\"0008\", RUN+=\"/bin/sh -c 'echo remove > /sys$env{DEVPATH}/uevent'\"\n"
"     ACTION==\"add\", ATTRS{idVendor}==\"3282\", ATTRS{idProduct}==\"0008\", SYMLINK+=\"mmpkeyboard\"\n"
"\n"
"    and reboot (or reload udev rules, but rebooting is safest+easiest).\n"
"\n");
        return(0);
        }
    }
    if (!usbhiddev_tries) printf("Retrying forever until the pad is found on USB.\n");
    else printf("Trying up to %d times to find the pad on USB.\n", usbhiddev_tries);
    printf("Using config file: %s\n", cfg_file);

    /* Read custom xdo event config */
    m = 0;
    fp = fopen(cfg_file, "r");
    if (fp) {
        while (fgets(cfg_tmp, CFG_LINE, fp)) {
            if (!cfg_tmp[0] || cfg_tmp[0] == '#' || cfg_tmp[0] == '\n') continue;
            strcpy(macrokey_syscall[m++], cfg_tmp);
        }
        fclose(fp);
        if (!m) printf("Warning: Config file '%s' contains no entries!\n", cfg_file);
        else printf("Read %d entries from config file '%s'.\n", m, cfg_file);
    } else {
        printf("Config file '%s' not found, generating one with defaults.\n", cfg_file);
        fp = fopen(cfg_file, "w");
        if (fp) {
            fprintf(fp, "# Config file for 'mmp', containing 36 lines in total:\n");
            fprintf(fp, "# Two system calls per key: 'Press down' and 'release', 2x12 = 24 lines.\n");
            fprintf(fp, "# One system call per key press when '-k' is specified, another 12 lines\n");
            fprintf(fp, "# Empty lines and lines starting on '#' are ignored.\n\n");
            fprintf(fp, "# 12 keys a 2 lines for normal operation:\n\n");
            for (n = 13; n <= 24; n++) fprintf(fp, "xdotool keydown F%d\nxdotool keyup F%d\n", n, n);
            fprintf(fp, "\n# 12 keys a 1 lines for operation under '-k' command-line option:\n\n");
            for (n = 13; n <= 24; n++) fprintf(fp, "xdotool key F%d\n", n);
            fclose(fp);
        } else printf("Warning: Unable to generate default config file '%s'.\n", cfg_file);
    }
    if (!m) {
        printf("Using default settings (xdotool keyup/keydown F13-F24 and key F13-F24).\n");
        for (n = 0; n < 12; n++) {
            sprintf(macrokey_syscall[n * 2], "xdotool keydown F%d\n", n + 13);
            sprintf(macrokey_syscall[n * 2 + 1], "xdotool keyup F%d\n", n + 13);
            sprintf(macrokey_syscall[n + 12 * 2], "xdotool key F%d\n", n + 13);
        }
    }

    /* Read all /dev/usb/hiddevN devices and scan which one is the correct one, assuming 'mmpkeyboard' from udev rules above. */
    /* Loop until the devices are ready. This is needed if we're called early, on system startup: */
    n = 0;
    while(n++ < usbhiddev_tries || !usbhiddev_tries) {
        dp = opendir("/dev/usb/");
        if (dp != NULL) {
            while((ep = readdir(dp)) != NULL) {
                if (!strstr(ep->d_name, "hiddev")) continue;
                printf("Checking %s .. ", ep->d_name);
                sprintf(syscall, "udevadm info --query=symlink -n /dev/usb/%s > /tmp/mmp.txt", ep->d_name);
                system(syscall);
                fp = fopen("/tmp/mmp.txt", "r");
                if (!fp) {
                    printf("Error: Cannot access /tmp/mmp.txt\n");
                    return(-6);
                }
                fgets(syscall, SYSCALLLEN, fp);
                fclose(fp);
                remove("/tmp/mmp.txt");
                syscall[strlen(syscall) - 1] = 0; //trim linefeed
                if (!strcmp(syscall, "mmpkeyboard")) {
                    printf("found 'mmpkeyboard' - Ok!\n");
                    sprintf(hiddev, "/dev/usb/%s", ep->d_name);
                    break;
                }
                else printf("'mmpkeyboard' not found.\n");
            }
            (void)closedir(dp);

            if (hiddev[0]) {
                printf("Mountain MacroPad found at %s\n", hiddev);
                break;
            }
            printf("Error: None of the /dev/usb/hiddevN devices was 'mmpkeyboard' (udev rules).\n");
        } else perror("Couldn't open /dev/usb/ directory");

        /* usbhiddev_tries != 1: Instead of quitting, we wait a bit and retry,
           in case the devices weren't ready yet (system startup phase) */
        if (!usbhiddev_tries) {
            printf("Attempt %d, retrying in 1s...\n", n);
            sleep(1);
            continue;
        } else if (n < usbhiddev_tries) {
            printf("Attempt %d of %d max, retrying in 1s...\n", n, usbhiddev_tries);
            sleep(1);
            continue;
        } else {
            printf("Attempt %d of %d max.\n", usbhiddev_tries, usbhiddev_tries);
            return(-2);
        }
    }

    /* This file access to /dev/usb/hiddevN requires root access usually and is therefore the reason why we must be run as root: */
    fp = fopen(hiddev, "r");
    if (!fp) {
        perror("Couldn't open the hiddev file");
        printf("Access requires root. Run this program with sudo: 'sudo ./mmp'.\n");
        return(-3);
    }

    if (!quiet) printf("\n");
    /* Loop forever, translating the M-key presses from /dev/usb/hiddevN to system calls (default: keyboard key events F13-24 via xdotool): */
    while(1) {
        usb_byte = fgetc(fp);

        for (n = 1; n < EVSIZE; n++) buf[n - 1] = buf[n];
        buf[EVSIZE - 1] = usb_byte;
        if (!buf[0]) continue;


        /* we read 512 Bytes, evaluate.. */
        printf("Read EVSIZE bytes.\n");

        mask1 = mask2 = 0;

        for (n = 0; n < 32; n++) {
            switch (n) {
            case 0:
                if (!memcmp(buf, mkey0, 16)) continue;
                n = -1; //failure
                break;
            case 21:
                mask1 = buf[21 * 16 + 4];
                if (!memcmp(buf +  21 * 16, mkeyN, 4) && !memcmp(buf +  21 * 16 + 5, mkeyN + 5, 11)) continue;
                n = -1; //failure
                break;
            case 23:
                mask2 = buf[23 * 16 + 12];
                if (!memcmp(buf +  23 * 16, mkeyN, 12) && !memcmp(buf +  23 * 16 + 13, mkeyN + 13, 3)) continue;
                n = -1; //failure
                break;
            default:
                if (!memcmp(buf + n * 16, mkeyN, 16)) continue;
                n = -1; //failure
                break;
            }
            if (n == -1) break; //failure
        }
        /* failure: didn't detect MacroPad key event pattern */
        if (n == -1) {
            memset(buf, 0, sizeof(buf));
            continue;
        }

        /* success */
        printf("M-mask 1: %#02x, M-mask 2: %#02x\n", mask1, mask2);

        /* scan for changes in key-holdings^^ */
        for (bit = 1; bit < 8; bit++) {
            bitmask = 0x1 << bit;

            /* no change in key-pressed state? */
            if ((mask1 & bitmask) == (mask1_prev & bitmask)) continue;

            if (mask1 & bitmask) {
                if (!quiet) printf("Pressed M%d.\n", bit);
                if (f_keypress)
                    sprintf(syscall, "%s", macrokey_syscall[bit - 1 + 12 * 2]); // key ('-k')
                else
                    sprintf(syscall, "%s", macrokey_syscall[(bit - 1) * 2]); // keydown
                if (!quiet) printf("Syscall: %s\n", syscall);
                if (!f_dryrun) system(syscall);
            } else {
                if (!quiet) printf("Released M%d.\n", bit);
                if (!f_keypress) {
                    sprintf(syscall, "%s", macrokey_syscall[(bit - 1) * 2 + 1]); // keyup
                    if (!quiet) printf("Syscall: %s\n", syscall);
                    if (!f_dryrun) system(syscall);
                }
            }
        }
        for (bit = 0; bit < 5; bit++) {
            bitmask = 0x1 << bit;

            /* no change in key-pressed state? */
            if ((mask2 & bitmask) == (mask2_prev & bitmask)) continue;

            if (mask2 & bitmask) {
                if (!quiet) printf("Pressed M%d.\n", bit + 8);
                if (f_keypress)
                    sprintf(syscall, "%s", macrokey_syscall[bit - 1 + 8 + 12 * 2]); // key ('-k')
                else
                    sprintf(syscall, "%s", macrokey_syscall[(bit - 1 + 8) * 2]); // keydown
                if (!quiet) printf("Syscall: %s\n", syscall);
                if (!f_dryrun) system(syscall);
            } else {
                if (!quiet) printf("Released M%d.\n", bit + 8);
                if (!f_keypress) {
                    sprintf(syscall, "%s", macrokey_syscall[(bit - 1 + 8) * 2 + 1]); // keyup
                    if (!quiet) printf("Syscall: %s\n", syscall);
                    if (!f_dryrun) system(syscall);
                }
            }
        }

        /* remember current M-keys' state, to compare for changes in the future */
        mask1_prev = mask1;
        mask2_prev = mask2;
        /* clean up to prepare for next key event */
        memset(buf, 0, sizeof(buf));
    }
}
