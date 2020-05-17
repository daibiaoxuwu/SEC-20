@delay[2000];
@is_cal[2000];
@rec[2000];
@src[2000];
@time_rec[2000];
@src_delay[2000];

@count[40];
@avg_delay[40];
@com_time[40];

@duty_cyle[50];

for ($i = 0; $i < 40; $i++) {
	@delay[$i] = 0;
	@time_rec[$i] = 0;
	@is_cal[$i] = 1;
	@rec[$i] = 1;
}

for ($i = 0; $i < 50; $i++) {
	for ($j = 0; $j < 40; $j++) {
		@rec[$i*40+$j] = 0;
	}
	$log_file = "$i.log";
	open fin, "<$log_file" or die "could not open file!\n";
	while (<fin>) {
      chomp;
      @log = split;
      if (@log[0] eq "delay") {
        $seq_no = @log[1];
        if ($seq_no < 40) {
        	@rec[$i*40+$seq_no] = 1;
        	@src[$i*40+$seq_no] = @log[2];
        	@time_rec[$i*40+$seq_no] = @log[3] * 65535 + @log[4];
        	@src_delay[$i*40+$seq_no] = @log[5] * 65535 + @log[6];
        }
      } elsif (@log[0] eq "flood") {
      	$seq_no = @log[1];
      	if ($seq_no+1 < 40) {
      		@time_rec[$seq_no+1] = @log[2] * 65535 + @log[3];
      	}
      } elsif (@log[0] eq "energy") {
        $radio_on_time = @log[3]*65535 + @log[4];
        $time_now = @log[1]*65535 + @log[2];
        @duty_cycle[$i] = $radio_on_time / $time_now;
      }
    }
    close fin;
}

$hops = 1;

while ($hops < 10) {
for ($i = 0; $i < 40; $i++) {
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*40+$i] == 1) {
			if (@is_cal[$j*40+$i] == 0) {
				if (@is_cal[@src[$j*40+$i]*40+$i] == 1) {
					@delay[$j*40+$i] = @delay[@src[$j*40+$i]*40+$i] + @src_delay[$j*40+$i] - @time_rec[@src[$j*40+$i]*40+$i];
					if ($hops == 1) {
						printf "hops $hops nodeid $j srcid @src[$j*40+$i] src_delay @src_delay[$j*40+$i] time_rec @time_rec[@src[$j*40+$i]*40+$i] delay @delay[$j*40+$i]\n";
					}
					@is_cal[$j*40+$i] = 1;
				} 
			}
		} 
	}
}
$hops++;
}

for ($i = 0; $i < 50; $i++) {
    printf "@duty_cycle[$i]\n";
}

for ($i = 0; $i < 40; $i++) {
	@count[$i]=0;
	@avg_delay[$i]=0;
	@com_time[$i]=0;
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*40+$i] == 1 && @is_cal[$j*40+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*40+$i];
			if (@delay[$j*40+$i] > @com_time[$i]) {
				@com_time[$i] = @delay[$j*40+$i];
			}
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
	}
	#printf "count @count[$i] average delay @avg_delay[$i]\n";
	printf "count @count[$i] average delay @avg_delay[$i] completion time @com_time[$i]\n";
}