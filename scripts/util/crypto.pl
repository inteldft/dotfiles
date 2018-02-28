#!/usr/bin/perl
use Switch;

my ($infile, $outfile) = @ARGV;
open(my $in, "<:encoding(UTF-8)", $infile)
    or die "Could not open file $infile $!";
open(my $out, ">", $outfile)
    or die "Could not open file $outfile $!";
while (my $row = <$in>) {
    chomp $row;
    my @chars = split(//, "$row");
    foreach my $char (@chars) {
        switch ($char) {
            case "A" { print $out "C" }
                case "B" { print $out "Z" }
                case "C" { print $out "Y" }
                case "D" { print $out "B" }
                case "E" { print $out "F" }
                case "F" { print $out "U" }
                case "G" { print $out "P" }
                case "H" { print $out "H" }
                case "I" { print $out "N" }
                case "J" { print $out "E" }
                case "K" { print $out "V" }
                case "L" { print $out "M" }
                case "M" { print $out "O" }
                case "N" { print $out "B" }
                case "O" { print $out "S" }
                case "P" { print $out "A" }
                case "Q" { print $out "D" }
                case "R" { print $out "F" }
                case "S" { print $out "L" }
                case "T" { print $out "Q" }
                case "U" { print $out "P" }
                case "V" { print $out "D" }
                case "W" { print $out "Q" }
                case "X" { print $out "Z" }
                case "Y" { print $out "L" }
                case "Z" { print $out "M" }
                case "a" { print $out "i" }
                case "b" { print $out "j" }
                case "c" { print $out "r" }
                case "d" { print $out "s" }
                case "e" { print $out "t" }
                case "f" { print $out "w" }
                case "g" { print $out "j" }
                case "h" { print $out "g" }
                case "i" { print $out "h" }
                case "j" { print $out "k" }
                case "k" { print $out "k" }
                case "l" { print $out "v" }
                case "m" { print $out "x" }
                case "n" { print $out "y" }
                case "o" { print $out "r" }
                case "p" { print $out "i" }
                case "q" { print $out "o" }
                case "r" { print $out "w" }
                case "s" { print $out "u" }
                case "t" { print $out "a" }
                case "u" { print $out "t" }
                case "v" { print $out "n" }
                case "w" { print $out "c" }
                case "x" { print $out "x" }
                case "y" { print $out "e" }
                case "z" { print $out "g" }
                else {
                    print $out $char;
                }
        }
    }
    print $out "\n";
}
close $out;
close $in;
