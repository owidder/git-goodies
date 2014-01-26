#!/usr/bin/perl

my @AllBranches = `git branch -a`;
for my $branch (@AllBranches) {
    if($branch =~ /^ *(found\/\d\d\d)$/) {
        printf "Delete branch: %s\n", $1;
        `git branch -D $1`;
    }
}