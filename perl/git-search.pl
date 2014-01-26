#!/opt/local/bin/perl

my $type = $ARGV[0]; # 'tree' or 'blob'?
my $pattern = $ARGV[1]; # filename to search for as regex
my $createBranches = $ARGV[2]; # 'y' if you want to create branches (only when search for 'tree')

##################################################################
# find all objects (blobs, trees, commits, tags) in .git/objects
##################################################################

my @AllSha1 = ();

# scan the packed files
my @PackedFiles = `find .git/objects/pack -name 'pack-*.idx'`;
for my $pf (@PackedFiles) {
    push(@AllSha1, $sha1);
}

# scan the packed and non-packed files
my @AllFiles = `find .git/objects/`;
for my $f (@AllFiles) {
	if($f =~ /([0-9a-f][0-9a-f])\/([0-9a-f]{38})/) {
        # non-packed
		my $sha1 = $1 . $2;
		push(@AllSha1, $sha1);
	}
	else if($f =~ /idx$/) {
	    # packed 
        my @Sha1List = `git show-index < $f | cut -f 2 -d ' '`;
        push(@AllSha1, @Sha1List);
	}
}

##################################################################
# find all trees or blobs containing the pattern
##################################################################

my $ctr = 0;
for my $foundSha1 (@AllSha1) {
	chomp $foundSha1;
	my $t = `git cat-file -t $foundSha1`;
	chomp $t;

	if($t eq $type) {

		my @Lines = `git cat-file -p $foundSha1`;
		for my $line (@Lines) {
			if($line =~ /$pattern/) {
				$ctr++;
				printf "found $type: %s\n", $foundSha1;
				if($type eq 'tree' && $createBranches eq 'y') {
					my $branchName = sprintf "found/%03s", $ctr;
					printf "created branch: %s\n", $branchName;
					`git commit-tree $foundSha1 -m "found $pattern" | xargs -I{} git branch $branchName {}`;
				}
				break;
			}
		}
	}
}
