@delay[3000];
@is_cal[3000];
@rec[3000];
@src[3000];
@hop[3000];
@time_rec[3000];
@src_delay[3000];

@count[20];
@avg_delay[20];

for ($i = 0; $i < 20; $i++) {
	@delay[20+$i] = 0;
	@time_rec[20+$i] = 0;
	@is_cal[20+$i] = 1;
	@rec[20+$i] = 1;
	@hop[20+$i] = 0;
}

$log_file = "flood.log";
open fin, "<$log_file" or "could not open file!\n";
while (<fin>) {
	chomp;
	@log = split;

	if (@log[0] eq "seq_no") { next; }

	$seq_no = @log[0];
	if ($seq_no < 20) {
		@rec[20+$seq_no] = 1;
		$time_flood = @log[1] * 65536 + @log[2];
		@time_rec[20+$seq_no] = $time_flood;
	}
}
close fin;

$log_file = "delay.log";
open fin, "<$log_file" or "could not open file!\n";
while (<fin>) {
	chomp;
	@log = split;

	if (@log[0] eq "nodeid") { next; }

	$nodeid = @log[0];
	$seq_no = @log[1];
	if ($seq_no < 20) {
		@rec[$nodeid*20+$seq_no] = 1;
        @src[$nodeid*20+$seq_no] = @log[2];
        $tmp_time = @log[3] * 65536 + @log[4];
        @time_rec[$nodeid*20+$seq_no] = $tmp_time;
        $tmp_time = @log[5] * 65536 + @log[6];
        @src_delay[$nodeid*20+$seq_no] = $tmp_time;
	}
}
close fin;

=pod
for ($i = 1; $i < 50; $i++) {
	for ($j = 0; $j < 20; $j++) {
		@rec[$i*20+$j] = 0;
	}
	$log_file = "$i.log";
	open fin, "<$log_file" or die "could not open file!\n";
	while (<fin>) {
      chomp;
      @log = split;

      if (@log[0] eq "delay:") {
        $seq_no = @log[1];
        if ($seq_no < 20) {
        	@rec[$i*20+$seq_no] = 1;
        	@src[$i*20+$seq_no] = @log[4];
        	@time_rec[$i*20+$seq_no] = @log[6];
        	@src_delay[$i*20+$seq_no] = @log[7];
        }
      } elsif (@log[0] eq "flood:") {
      	$seq_no = @log[1];
      	if ($seq_no < 20) {
      		@rec[$i*20+$seq_no] = 1;
      		@time_rec[$i*20+$seq_no] = @log[2];
      	}
      }
    }
    close fin;
}
=cut
$hops = 1;

while ($hops < 20) {
for ($i = 0; $i < 20; $i++) {
	for ($j = 1; $j < 150; $j++) {
		if (@rec[$j*20+$i] == 1) {
			if (@is_cal[$j*20+$i] == 0) {
				if (@is_cal[@src[$j*20+$i]*20+$i] == 1) {
					@delay[$j*20+$i] = @delay[@src[$j*20+$i]*20+$i] + @src_delay[$j*20+$i] - @time_rec[@src[$j*20+$i]*20+$i];
					@hop[$j*20+$i] = @hop[@src[$j*20+$i]*20+$i] + 1;
					#if ($hops == 1) {
					#	printf "hops $hops nodeid $j srcid @src[$j*20+$i] src_delay @src_delay[$j*20+$i] delay @delay[$j*20+$i]\n";
					#}
					printf "seq $i hop @hop[$j*20+$i] nodeid $j delay @delay[$j*20+$i]\n";
					@is_cal[$j*20+$i] = 1;
				} 
			}
		} 
	}
}
$hops++;
}


for ($i = 0; $i < 20; $i++) {
	@count[$i]=0;
	@avg_delay[$i]=0;
	for ($j = 1; $j < 150; $j++) {
		if (@rec[$j*20+$i] == 1 && @is_cal[$j*20+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*20+$i];
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
	}
	printf "count @count[$i] average delay @avg_delay[$i]\n";
}