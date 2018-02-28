#!/usr/intel/bin/perl
# Author: Todd Larason <jtl@molehill.org>
# $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $

# use the resources for colors 0-15 - usually more-or-less a
# reproduction of the standard ANSI colors, but possibly more
# pleasing shades
use strict;
use warnings;

# colors 16-231 are a 6x6x6 color cube
for my $red (0 .. 5) {
    for my $green (0 .. 5) {
        for my $blue (0 .. 5) {
            printf(
                "\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
                16 + ($red * 36) + ($green * 6) + $blue,
                ($red   ? ($red * 40 + 55)   : 0),
                ($green ? ($green * 40 + 55) : 0),
                ($blue  ? ($blue * 40 + 55)  : 0)
            );
        }
    }
}

# colors 232-255 are a grayscale ramp, intentionally leaving out
# black and white
for my $gray (0..23) {
    my $level = ($gray * 10) + 8;
    printf("\x1b]4;%d;rgb:%2.2x/%2.2x/%2.2x\x1b\\",
           232 + $gray, $level, $level, $level);
}

# display the colors

# first the system ones:
print "System colors:\n";
for my $color (0..7) {
    print "\x1b[48;5;${color}m  ";
}
print "\x1b[0m\n";
for my $color (8..15) {
    print "\x1b[48;5;${color}m  ";
}
print "\x1b[0m\n\n";

# now the color cube
print "Color cube, 6x6x6:\n";
for my $green (0..5) {
    for my $red (0..5) {
        for my $blue (0..5) {
            my $color = 16 + ($red * 36) + ($green * 6) + $blue;
            print "\x1b[48;5;${color}m  ";
        }
        print "\x1b[0m ";
    }
    print "\n";
}


# now the grayscale ramp
print "Grayscale ramp:\n";
for my $color (232..255) {
    print "\x1b[48;5;${color}m  ";
}
print "\x1b[0m\n";
