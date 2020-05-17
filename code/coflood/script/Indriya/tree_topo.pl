@node[150];
@neighbor[2100];
@link[2100];
@sender[150];

for ($i = 0; $i < 150; $i++) {
    @node[$i] = 0;
    @sender[$i] = 0;
}

for ($i = 0; $i < 2100; $i++) {
    @neighbor[$i] = 0;
    @link[$i] = 0;
}

$tree_file = "tree.dat";
open fin, "<$tree_file" or "could not open file!\n";
while (<fin>) {
    chomp;
    @log = split;

    if (@log[0] eq "addr") { next; }

    $id = @log[0];
    @node[$id] = @log[1];

    printf "Node $id has @node[$id] neighbors:\n";

    for ($i = 0; $i < @node[$id]; $i++) {
        @neighbor[$id*14+$i] = @log[2+$i];
        @link[$id*14+$i] = @log[16+$i];
        printf "Neighbor @log[2+$i], Link Quality @log[16+$i]\n";
    }
}

$root = 3;
@hop[150];

for ($i = 0; $i < 150; $i++) {
    @hop[$i] = 0;
}

@hop[$root] = 1;
$max_hop = 0;
$change = 0;

while ($change == 0) {
    $change = 1;
    for ($i = 0; $i < 150; $i++) {
        if (@hop[$i] != 0) {
            for ($j = 0; $j < $node[$i]; $j++) {
                $new_hop = @hop[$i] + 1;
                if ( (@hop[@neighbor[$i*14+$j]] == 0) || ($new_hop < @hop[@neighbor[$i*14+$j]]) ) {
                    @hop[@neighbor[$i*14+$j]] = $new_hop;
                    @sender[@neighbor[$i*14+$j]] = $i;
                    $change = 0;
                }
            }
        }
    }
}

for ($i = 0; $i < 150; $i++) {
    if (@hop[$i] > $max_hop) {
        $max_hop = @hop[$i];
    }
}

for ($i = 1; $i <= $max_hop; $i++) {
    printf "Hop $i:";
    for ($j = 0; $j < 150; $j++) {
        if (@hop[$j] == $i) {
            printf " $j(@sender[$j])";
        }
    }
    printf "\n"
}
printf "Network Hop $max_hop\n";
