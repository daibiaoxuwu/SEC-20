@node[150];
@ebw[150];
@path_ebw[150];
@elder_id[150];
@delay[150];
@children_num[150];
@is_sender[150];

$total_node = 0;
$total_sender = 0;

for ($i = 0; $i < 150; $i++) {
    @node[$i] = 0;
}

$s_counter = 0;

$sender_file = "sender.dat";
open fin, "<$sender_file" or "could not open file!\n";
while (<fin>) {
    chomp;
    @log = split;

    if (@log[0] eq "id") { next; }

    $id = @log[0];
    @node[$id] = 1;
    @ebw[$id] = @log[1];
    @path_ebw[$id] = @log[2];
    @elder_id[$id] = @log[3];
    @delay[$id] = @log[4];
    @children_num[$id] = @log[5];
    @is_sender[$id] = @log[6];

    $total_node++;
    if (@log[6] == 1) {
        $total_sender++;
    }

#    if ( ($id % 6) == 0 ) {
#        $s_counter++;
#        printf "$id ";
#    }
}

# printf "$s_counter\n";

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
        if ( (@hop[$i] == 0) && (@hop[@elder_id[$i]] != 0) ) {
            @hop[$i] = @hop[@elder_id[$i]] + 1;
            $change = 0;
        }
    }
}

for ($i = 0; $i < 150; $i++) {
    if (@hop[$i] > $max_hop) {
        $max_hop = @hop[$i];
    }
}

$connected_node = 0;

for ($i = 1; $i <= $max_hop; $i++) {
    printf "Hop $i:\n";
    for ($j = 0; $j < 150; $j++) {
        if (@hop[$j] == $i) {
            $connected_node++;
            printf "    $j(EBW @ebw[$j] | Path_EBW @path_ebw[$j] | Elder_ID @elder_id[$j] | Delay @delay[$j] | Children# @children_num[$j] | Is_Sender @is_sender[$j])\n";
        }
    }
}
printf "Network Hop $max_hop, Total Node $total_node, Connected Node $connected_node, Total Sender $total_sender\n";

$total_cost = 0;

for ($i = 0; $i < 150; $i++) {
    if (@is_sender[$i] == 1) {
        $total_cost += @delay[$i];
        printf "$i ";
    }
}
printf "\ntotal cost: $total_cost\n";

#$s_counter = 0;
#for ($i = 0; $i < 150; $i++) {
#  if ( ($i % 6) == 0 && @is_sender[$i] == 1 ) {
#    $s_counter++;
#    printf "$i ";
#  }
#}
#printf "$s_counter\n";

#for ($i = 0; $i < 150; $i++) {
#  if ( ($i % 4) == 0 && @is_sender[$i] == 0 && @node[$i] == 1) {
#      printf "$i(@hop[$i]) ";
#  }
#}
#printf "\n";

#for ($i = 0; $i < 150; $i++) {
#  if ( ($i % 3) == 0 && @is_sender[$i] == 0 && @node[$i] == 1) {
#      printf "$i(@hop[$i]) ";
#  }
#}
#printf "\n";
