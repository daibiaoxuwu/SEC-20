@delay[500];
@is_cal[500];
@rec[500];
@src[500];
@time_rec[500];
@src_delay[500];

@count[10];
@avg_delay[10];

for ($i = 0; $i < 10; $i++) {
	@delay[$i] = 0;
	@time_rec[$i] = 0;
	@is_cal[$i] = 1;
	@rec[$i] = 1;
}

for ($i = 0; $i < 50; $i++) {
	for ($j = 0; $j < 10; $j++) {
		@rec[$i*10+$j] = 0;
	}
	$log_file = "$i.log";
	open fin, "<$log_file" or die "could not open file!\n";
	while (<fin>) {
      chomp;
      @log = split;
      if (@log[0] eq "delay") {
        $seq_no = @log[1];
        if ($seq_no < 10) {
        	@rec[$i*10+$seq_no] = 1;
        	@src[$i*10+$seq_no] = @log[2];
        	@time_rec[$i*10+$seq_no] = @log[3] * 65535 + @log[4];
        	@src_delay[$i*10+$seq_no] = @log[5] * 65535 + @log[6];
        }
      } elsif (@log[0] eq "flood") {
      	$seq_no = @log[1];
      	if ($seq_no+1 < 10) {
      		@time_rec[$seq_no+1] = @log[2] * 65535 + @log[3];
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
					if ($hops == 1) {
						printf "hops $hops nodeid $j srcid @src[$j*10+$i] src_delay @src_delay[$j*10+$i] time_rec @time_rec[@src[$j*10+$i]*10+$i] delay @delay[$j*10+$i]\n";
					}
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
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
	}
	printf "count @count[$i] average delay @avg_delay[$i]\n";
}