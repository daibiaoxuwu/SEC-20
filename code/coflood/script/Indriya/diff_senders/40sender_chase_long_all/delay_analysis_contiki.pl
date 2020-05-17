@delay[6000];
@is_cal[6000];
@rec[6000];
@src[6000];
@hop[6000];
@time_rec[6000];
@src_delay[6000];
@tail[6000];

@count[40];
@avg_delay[40];
@comp_time[40];

@duty_cycle[150];

for ($i = 0; $i < 150; $i++) {
	@duty_cycle[$i] = 0;
}

for ($i = 0; $i < 40; $i++) {
	@delay[3*40+$i] = 0;
	@time_rec[3*40+$i] = 0;
	@is_cal[3*40+$i] = 1;
	@rec[3*40+$i] = 1;
	@hop[3*40+$i] = 0;
}

$log_file = "flood.log";
open fin, "<$log_file" or "could not open file!\n";
while (<fin>) {
	chomp;
	@log = split;

	if (@log[0] eq "seq_no") { next; }

	$seq_no = @log[0];
	if ($seq_no < 40) {
		@rec[3*40+$seq_no] = 1;
		$time_flood = @log[1] * 65536 + @log[2];
		@time_rec[3*40+$seq_no] = $time_flood;
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
	if ($seq_no < 40) {
		@rec[$nodeid*40+$seq_no] = 1;
        @src[$nodeid*40+$seq_no] = @log[2];
        $tmp_time = @log[3] * 65536 + @log[4];
        @time_rec[$nodeid*40+$seq_no] = $tmp_time;
        $tmp_time = @log[5] * 65536 + @log[6];
        @src_delay[$nodeid*40+$seq_no] = $tmp_time;
	}
}
close fin;

$log_file = "energy.log";
open fin, "<$log_file" or "could not open file!\n";
while (<fin>) {
	chomp;
	@log = split;

	if (@log[0] eq "nodeid") { next; }

	$nodeid = @log[0];
    $total_time = @log[1] * 65536 + @log[2];
    $radio_on = @log[3] * 65536 + @log[4];
	@duty_cycle[$nodeid] = $radio_on / $total_time;
}
close fin;

$log_file = "tail.log";
open fin, "<$log_file" or "could not open file!\n";
while (<fin>) {
	chomp;
	@log = split;

	if (@log[0] eq "nodeid") { next; }

	$nodeid = @log[0];
	$seq_no = @log[1];
	$tail_time = @log[2] * 65536 + @log[3];

	if ($seq_no < 40) {
	  @tail[$nodeid*40+$seq_no] = $tail_time;
    }
}

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
for ($i = 0; $i < 40; $i++) {
	for ($j = 1; $j < 150; $j++) {
		if (@rec[$j*40+$i] == 1) {
			if (@is_cal[$j*40+$i] == 0) {
				if (@is_cal[@src[$j*40+$i]*40+$i] == 1) {
					@delay[$j*40+$i] = @delay[@src[$j*40+$i]*40+$i] + @src_delay[$j*40+$i] - @time_rec[@src[$j*40+$i]*40+$i];
					@hop[$j*40+$i] = @hop[@src[$j*40+$i]*40+$i] + 1;
					#if ($hops == 1) {
					#	printf "hops $hops nodeid $j srcid @src[$j*20+$i] src_delay @src_delay[$j*20+$i] delay @delay[$j*20+$i]\n";
					#}
					#printf "seq $i hop @hop[$j*20+$i] nodeid $j delay @delay[$j*20+$i]\n";
					@is_cal[$j*40+$i] = 1;
				}
			}
		}
	}
}
$hops++;
}

$avg_duty_cycle = 0;
$duty_cycle_count = 0;
for ($i = 0; $i < 150; $i++) {
	if (@duty_cycle[$i] != 0) {
		$avg_duty_cycle += @duty_cycle[$i];
		$duty_cycle_count++;
		#printf "@duty_cycle[$i]\n";
	}
}
$avg_duty_cycle = $avg_duty_cycle / $duty_cycle_count;
printf "average duty cycle $avg_duty_cycle\n";

@tail_length[6000];
$counter = 0;

$avg_comp_time = 0;
$comp_time_count = 0;

for ($i = 0; $i < 40; $i++) {
	@count[$i]=0;
	@avg_delay[$i]=0;
	@comp_time[$i]=0;
	for ($j = 1; $j < 150; $j++) {
		if (@rec[$j*40+$i] == 1 && @is_cal[$j*40+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*40+$i];
			if (@delay[$j*40+$i] > @com_time[$i]) {
				@com_time[$i] = @delay[$j*40+$i];
			}
			if ($j != 3) {
			  @tail_length[$counter] = @time_rec[$j*40+$i] - @tail[$j*40+$i];

			  $counter++;
			}
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
	}
	#printf "count @count[$i] average delay @avg_delay[$i]\n";
	printf "count @count[$i] average delay @avg_delay[$i] completion time @com_time[$i]\n";

	if (@count[$i] > 40 && @com_time[$i] < 10000) {
		$avg_comp_time += @com_time[$i];
		$comp_time_count++;
	}
}

$avg_comp_time = $avg_comp_time / $comp_time_count;
printf "$comp_time_count available records. average completion time $avg_comp_time\n";

printf "$counter\n";

if ($counter != 0) {
  for ($j = 1; $j < $counter; $j++) {
  	$k = $j - 1;
  	$tmp_tail = @tail_length[$j];
  	while ($tmp_tail < @tail_length[$k] and $k >= 0) {
  	  @tail_length[$k+1] = @tail_length[$k];
  	  $k--;
  	}
  	@tail_length[$k+1] = $tmp_tail;
  }

=pod
  $data = "tail_time_cdf.txt";
  open $dataout, ">$data" or die "could not open $data!\n";
  $cdf_count = 0;
  $cdf_delta = 0;
  for ($j = 0; $j < 5000 and $cdf_count < $tail_count; $j++) {
  	while ($cdf_count < $tail_count and @all_tail[$cdf_count] <= $cdf_delta) {
  		#printf "@delta_valid[$cdf_count]\n";
  		$cdf_count++;
  	}
  	$percentage = $cdf_count / $tail_count;
  	print $dataout "$cdf_delta $percentage\n";
  	$cdf_delta = $cdf_delta + 2;
  }
  close $dataout;
=cut
  $tail25 = @tail_length[int($counter*0.25)];
  $tail50 = @tail_length[int($counter*0.5)];
  $tail75 = @tail_length[int($counter*0.75)];
  printf "@tail_length[0] $tail25 $tail50 $tail75 @tail_length[$counter-1]\n";
}
