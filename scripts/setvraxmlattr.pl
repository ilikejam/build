#!/usr/bin/perl -i
# Script to update/add a Property to a vra blueprint xml file
# Run as:
#   $0 -c -a <attribute> -v <defaultvalue> -e <encrypted {true|false}> -h <hidden {true|false}> -p <promptuser {true|false}> <file.xml>
# or
#   $0 -b -a <attribute> -v <defaultvalue> <file.xml>
# Input: single filename
# Output: in-place (apologies to Ken & Dennis)
use strict;
use warnings;
use XML::Simple;
use Data::Dumper;
use Getopt::Std;

# Method override to keep the Properties attributes in the original order.
# This isn't really required, but should reduce git diffs.
package MyXMLSimple;
use base 'XML::Simple';
sub sorted_keys
{
   my ($self, $name, $hashref) = @_;
   if ($name eq 'Property')
   {
      return ('Name', 'DefaultValue', 'Encrypted', 'Hidden', 'PromptUser');
   }
   return $self->SUPER::sorted_keys($name, $hashref);
}

package main;

my ($type, $attribute, $value, $encrypted, $hidden, $promptuser);

my %args=();
getopts("bca:v:e:h:p:", \%args);

if ($args{c}) {
    $type = "prop";
    $attribute  = $args{a} or die "No attribute name (-a) set.";
    $value       = $args{v} or $value = "";
    $encrypted   = $args{e} or die "No encryption (-e) set. Should be 'true' or 'false'.";
    $hidden      = $args{h} or die "No hidden (-h) set. Should be 'true' or 'false'.";
    $promptuser  = $args{p} or die "No prompt user (-p) set. Should be 'true' or 'false'.";
} elsif ($args{b}) {
    $type = "meta";
    $attribute  = $args{a} or die "No attribute name (-a) set.";
    $value      = $args{v} or $value = "";
} else {
    die "One of -b or -c needs to be set"
}

my $textin = do { local $/; <> };
my $parser = MyXMLSimple->new(ForceArray => 0, KeepRoot => 0, RootName => "Doc");
my $obj = $parser->XMLin($textin);

if ($type eq "prop") {
    my $found = 0;
    if (defined($obj->{CustomProperties}->{Property})) {
        if (ref($obj->{CustomProperties}->{Property}) ne "ARRAY") {
            $obj->{CustomProperties}->{Property} = [$obj->{CustomProperties}->{Property}];
        }
        for (@{$obj->{CustomProperties}->{Property}}) {
            if (defined $_->{Name}) {
                if ($_->{Name} eq $attribute) {
                    $_->{DefaultValue} = $value;
                    $_->{Encrypted}    = $encrypted;
                    $_->{Hidden}       = $hidden;
                    $_->{PromptUser}   = $promptuser;
                    $found = 1;
                }
            }
        }
    }
                
    if (!$found) {
        my %hash = ( Name => $attribute,
                     DefaultValue => $value,
                     Encrypted => $encrypted,
                     Hidden => $hidden,
                     PromptUser => $promptuser );
        if (!defined($obj->{CustomProperties}->{Property})) {
            $obj->{CustomProperties}->{Property} = [\%hash];
        } elsif (ref($obj->{CustomProperties}->{Property}) ne "ARRAY") {
            $obj->{CustomProperties}->{Property} = [$obj->{CustomProperties}->{Property}];
            push @{$obj->{CustomProperties}->{Property}}, \%hash;
        } else {
            push @{$obj->{CustomProperties}->{Property}}, \%hash;
        }
    }
} else {
    $obj->{Blueprint}->{$attribute} = $value;
}

# 'sort -i' for the property array
if (defined($obj->{CustomProperties}) && ref($obj->{CustomProperties}->{Property}) eq "ARRAY") {
    @{$obj->{CustomProperties}->{Property}} = sort { lc($a->{Name})         cmp lc($b->{Name})         or 
                                                     lc($a->{DefaultValue}) cmp lc($b->{DefaultValue}) or
                                                     lc($a->{Encrypted})    cmp lc($b->{Encrypted})    or
                                                     lc($a->{Hidden})       cmp lc($b->{Hidden})       or
                                                     lc($a->{PromptUser})   cmp lc($b->{PromptUser}) } @{$obj->{CustomProperties}->{Property}};
}
    
# Array-ify the Blueprints section elements to force unfolding
if (defined($obj->{Blueprint})) {
    while (my ($k,$v) = each %{$obj->{Blueprint}}) {
        $obj->{Blueprint}->{$k} = [$v];
    }
}

my $textout = $parser->XMLout($obj);
$textout =~ s| />\n|/>\n|g; # Strip spaces before tag-close
$textout =~ s/\n( *)/\n$1$1/g; # Double the indent to 4 spaces

print $textout;
