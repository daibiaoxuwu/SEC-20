@node[150];
@neighbor[22500];
@link[22500];
@rssi[22500];

for ($i = 0; $i < 150; $i++) {
    @node[$i] = 0;
}

for ($i = 0; $i < 22500; $i++) {
    @neighbor[$i] = 0;
    @link[$i] = 0;
    @rssi[$i] = 0;
}

$topo_file = "topo2.dat";
open fin, "<$topo_file" or "could not open file!\n";
while (<fin>) {
    chomp;
    @log = split;

    if (@log[0] eq "id") { next; }

    $id = @log[0];
    $src = @log[1];
    $rssi = @log[2];

    #printf "$id $src\n";

    if ($rssi > 127) {
        $rssi = $rssi - 256 - 45;
    } else {
        $rssi = $rssi - 45;
    }

    $index = $src * 150 + $id;
    @neighbor[$index] = 1;
    @link[$index] = @link[$index] + 1;
    @rssi[$index] = @rssi[$index] + $rssi;
}

for ($i = 0; $i < 150; $i++) {
    for ($j = 0; $j < 150; $j++) {
        $index = $i * 150 + $j;
        if (@neighbor[$index] == 1) {
            $node[$i]++;
        }
    }
}

$total_node = 0;
$max_neighbor = 0;
$min_neighbor = 150;
$avg_neighbor = 0;

for ($i = 0; $i < 150; $i++) {
    for ($j = 0; $j < 150; $j++) {
        $index = $i * 150 + $j;
        if (@neighbor[$index] == 1) {
            @rssi[$index] = @rssi[$index] / @link[$index];
            @link[$index] = @link[$index] / 10;
            if (@link[$index] < 0.9) {
                @neighbor[$index] = 0;
                @node[$i]--;
            } else {
                printf "link[$i, $j]: quality @link[$index], rssi @rssi[$index]\n";
            }
        }
    }
    if (@node[$i] > 0) {
        $total_node++;
        if (@node[$i] < $min_neighbor) {
            $min_neighbor = @node[$i];
        }
        if (@node[$i] > $max_neighbor) {
            $max_neighbor = @node[$i];
        }
        $avg_neighbor += @node[$i];
        printf "Node $i has $node[$i] neighbors.\n";
    }
}

$avg_neighbor = $avg_neighbor / $total_node;

printf "Total node: $total_node, neighbor: $max_neighbor $avg_neighbor $min_neighbor\n";

$root = 3;
@hop[150];
@is_sender[150];

for ($i = 0; $i < 150; $i++) {
    @hop[$i] = 0;
    @is_sender[$i] = 0;
}

@hop[$root] = 1;
$max_hop = 0;
$change = 0;

while ($change == 0) {
    $change = 1;
    for ($i = 0; $i < 150; $i++) {
        if (@hop[$i] != 0) {
            for ($j = 0; $j < 150; $j++) {
                $index = $i * 150 + $j;
                if (@neighbor[$index] == 1) {
                    $new_hop = @hop[$i] + 1;
                    if ( (@hop[$j] == 0) || ($new_hop < @hop[$j]) ) {
                        @hop[$j] = $new_hop;
                        @is_sender[$i] = 1;
                        $change = 0;
                    }
                }
            }
        }
    }
}

$total_sender = 0;
for ($i = 0; $i < 150; $i++) {
    if (@hop[$i] > $max_hop) {
        $max_hop = @hop[$i];
    }
    $total_sender += @is_sender[$i];
}

for ($i = 1; $i <= $max_hop; $i++) {
    printf "Hop $i:";
    for ($j = 0; $j < 150; $j++) {
        if (@hop[$j] == $i) {
            printf " $j";
        }
    }
    printf "\n";
}
printf "Network Hop $max_hop Total Sender $total_sender\n";
