@node[50];
@neighbor[2500];
@link[2500];
@rssi[2500];

for ($i = 0; $i < 50; $i++) {
    @node[$i] = 0;
}

for ($i = 0; $i < 2500; $i++) {
    @neighbor[$i] = 0;
    @link[$i] = 0;
    @rssi[$i] = 0;
}

for ($i = 0; $i < 50; $i++) {
$topo_file = "$i.log";
open fin, "<$topo_file" or "could not open file!\n";
while (<fin>) {
    chomp;
    @log = split;

    #if (@log[0] eq "id") { next; }

    $id = @log[3];
    $src = @log[1];
    $rssi = @log[4];

    #printf "$id $src\n";

    if ($rssi > 127) {
        $rssi = $rssi - 256 - 45;
    } else {
        $rssi = $rssi - 45;
    }

    $index = $src * 50 + $id;
    @neighbor[$index] = 1;
    @link[$index] = @link[$index] + 1;
    @rssi[$index] = @rssi[$index] + $rssi;
}
}

for ($i = 0; $i < 50; $i++) {
    for ($j = 0; $j < 50; $j++) {
        $index = $i * 50 + $j;
        if (@neighbor[$index] == 1) {
            $node[$i]++;
        }
    }
}

$total_node = 0;
$max_neighbor = 0;
$min_neighbor = 50;
$avg_neighbor = 0;

for ($i = 0; $i < 50; $i++) {
    for ($j = 0; $j < 50; $j++) {
        $index = $i * 50 + $j;
        if (@neighbor[$index] == 1) {
            @rssi[$index] = @rssi[$index] / @link[$index];
            @link[$index] = @link[$index] / 10;
            if (@link[$index] < 0.8) {
                @neighbor[$index] = 0;
                @node[$i]--;
            } else {
                printf "link[$i, $j]: quality @link[$index], rssi @rssi[$index]\n";
            }
        }
    }
    if (@node[$i] > 0) {
        if (@node[$i] > $max_neighbor) {
            $max_neighbor = @node[$i];
        }
        if (@node[$i] < $min_neighbor) {
            $min_neighbor = @node[$i];
        }
        $avg_neighbor += @node[$i];
        $total_node++;
        printf "Node $i has $node[$i] neighbors.\n";
    }
}

$avg_neighbor = $avg_neighbor / $total_node;

printf "Total node: $total_node neighbor: $max_neighbor $avg_neighbor $min_neighbor\n";

$root = 0;
@hop[50];

for ($i = 0; $i < 50; $i++) {
    @hop[$i] = 0;
}

@hop[$root] = 1;
$max_hop = 0;
$change = 0;

while ($change == 0) {
    $change = 1;
    for ($i = 0; $i < 50; $i++) {
        if (@hop[$i] != 0) {
            for ($j = 0; $j < 50; $j++) {
                $index = $i * 50 + $j;
                if (@neighbor[$index] == 1) {
                    $new_hop = @hop[$i] + 1;
                    if ( (@hop[$j] == 0) || ($new_hop < @hop[$j]) ) {
                        @hop[$j] = $new_hop;
                        $change = 0;
                    }
                }
            }
        }
    }
}

for ($i = 0; $i < 50; $i++) {
    if (@hop[$i] > $max_hop) {
        $max_hop = @hop[$i];
    }
}

for ($i = 1; $i <= $max_hop; $i++) {
    printf "Hop $i:";
    for ($j = 0; $j < 50; $j++) {
        if (@hop[$j] == $i) {
            printf " $j";
        }
    }
    printf "\n";
}
printf "Network Hop $max_hop\n";

@link_diff[2500];

for ($link_thresh=1; $link_thresh <= 10; $link_thresh++) {
  $link_counter = 0;
  $sum_diff = 0;
  for ($i = 0; $i < 2500; $i++) {
    @link_diff[$i] = 2;
  }

  for ($i = 0; $i < 50; $i++) {
    for ($j = 0; $j < 50; $j++) {
        $index = $i * 50 + $j;
        if ( (@link[$index] != 0) and (@link[$index]*10 <= $link_thresh) and (@link[$index]*10 > $link_thresh-1) ) {
            $reverse_index = $j * 50 + $i;
            @link_diff[$link_counter] = abs(@link[$index] - @link[$reverse_index]);
            $sum_diff += @link_diff[$link_counter];
            $link_counter++;
        }
    }
  }

  if ($link_counter > 0) {
    @link_diff = sort {$a <=> $b} @link_diff;
    $sum_diff = $sum_diff / $link_counter;
    $max = @link_diff[$link_counter-1];
    $seven = @link_diff[int($link_counter*3/4)];
    $median = @link_diff[int($link_counter/2)];
    $two = @link_diff[int($link_counter/4)];
    $min = @link_diff[0];
    printf "$link_thresh $link_counter $sum_diff $max $seven $median $two $min\n";
  }

}
