# gathering the script and samplesheet
script=$1
#script="workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.array.sh"

samplesheet=$2
#samplesheet="workflow/qscripts/finemap/causal_db/lc.sgls_finemap_with_hichip.samplesheet.txt"

# determining the intervals details for the given job/samplesheet
ss_len=$( wc -l $samplesheet | cut -d " " -f 1 )
interval_size=1000
intervals=( $(seq 1 $interval_size $ss_len) $ss_len )
num_intervals=$(expr "${#intervals[@]}" - 1)

# printing out the intervals
for i in $(seq 0 $(expr $num_intervals - 1));
do
    start="${intervals[i]}"
    end="${intervals[i + 1]}"
    array_end=$(expr "${intervals[i + 1]}" - "${intervals[i]}" + 1)
    echo "sbatch --array=1-${array_end} --export istart=${start},iend=${end} ${script}"
done