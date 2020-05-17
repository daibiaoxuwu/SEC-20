@delay[500];
@is_cal[500];
@rec[500];
@src[500];
@hop[500];
@time_rec[500];
@src_delay[500];

@count[10];
@avg_delay[10];

for ($i = 0; $i < 10; $i++) {
	@delay[10+$i] = 0;
	@time_rec[10+$i] = 0;
	@is_cal[10+$i] = 1;
	@rec[10+$i] = 1;
	@hop[10+$i] = 0;
}

for ($i = 1; $i < 50; $i++) {
	for ($j = 0; $j < 10; $j++) {
		@rec[$i*10+$j] = 0;
	}
	$log_file = "$i.log";
	open fin, "<$log_file" or die "could not open file!\n";
	while (<fin>) {
      chomp;
      @log = split;

      if (@log[0] eq "delay:") {
        $seq_no = @log[1];
        if ($seq_no < 10) {
        	@rec[$i*10+$seq_no] = 1;
        	@src[$i*10+$seq_no] = @log[4];
        	@time_rec[$i*10+$seq_no] = @log[6];
        	@src_delay[$i*10+$seq_no] = @log[7];
        }
      } elsif (@log[0] eq "flood:") {
      	$seq_no = @log[1];
      	if ($seq_no < 10) {
      		@rec[$i*10+$seq_no] = 1;
      		@time_rec[$i*10+$seq_no] = @log[2];
      	}
      }
    }
    close fin;
}

$hops = 1;

while ($hops < 10) {
for ($i = 0; $i < 10; $i++) {
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*10+$i] == 1) {
			if (@is_cal[$j*10+$i] == 0) {
				if (@is_cal[@src[$j*10+$i]*10+$i] == 1) {
					@delay[$j*10+$i] = @delay[@src[$j*10+$i]*10+$i] + @src_delay[$j*10+$i] - @time_rec[@src[$j*10+$i]*10+$i];
					@hop[$j*10+$i] = @hop[@src[$j*10+$i]*10+$i] + 1;
					#if ($hops == 1) {
					#	printf "hops $hops nodeid $j srcid @src[$j*10+$i] src_delay @src_delay[$j*10+$i] delay @delay[$j*10+$i]\n";
					#}
					printf "seq $i hop @hop[$j*10+$i] nodeid $j delay @delay[$j*10+$i]\n";
					@is_cal[$j*10+$i] = 1;
				} 
			}
		} 
	}
}
$hops++;
}


for ($i = 0; $i < 10; $i++) {
	@count[$i]=0;
	@avg_delay[$i]=0;
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*10+$i] == 1 && @is_cal[$j*10+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*10+$i];
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i] / 128;
	}
	printf "count @count[$i] average delay @avg_delay[$i]\n";
}