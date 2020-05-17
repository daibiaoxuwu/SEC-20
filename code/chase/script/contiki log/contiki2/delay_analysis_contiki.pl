@delay[1000];
@is_cal[1000];
@rec[1000];
@src[1000];
@hop[1000];
@time_rec[1000];
@src_delay[1000];

@count[20];
@avg_delay[20];
@com_time[20];

for ($i = 0; $i < 20; $i++) {
	@delay[20+$i] = 0;
	@time_rec[20+$i] = 0;
	@is_cal[20+$i] = 1;
	@rec[20+$i] = 1;
	@hop[20+$i] = 0;
}

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

$hops = 1;

while ($hops < 10) {
for ($i = 0; $i < 20; $i++) {
	for ($j = 1; $j < 50; $j++) {
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
=pod
	@count[$i]=0;
	@avg_delay[$i]=0;
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*20+$i] == 1 && @is_cal[$j*20+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*20+$i];
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i] / 128;
	}
	printf "count @count[$i] average delay @avg_delay[$i]\n";
=cut

@count[$i]=0;
	@avg_delay[$i]=0;
	@com_time[$i]=0;
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*20+$i] == 1 && @is_cal[$j*20+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*20+$i];
			if (@delay[$j*20+$i] > @com_time[$i]) {
				@com_time[$i] = @delay[$j*20+$i];
			}
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i] / 128;
		@com_time[$i] = @com_time[$i] / 128;
	}
	printf "count @count[$i] average delay @avg_delay[$i] completion time @com_time[$i]\n";
}