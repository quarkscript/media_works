#!/bin/bash
if ($(echo $@ | grep -q --regexp="-h" --regexp="help")); then
echo '
## nit - "normalize it" (bash script that normalize the volume of audio files)
## Required: bash-like shell env., ffmpeg, grep, sed, wc, tail, head, find
## Use: ./nit [audio file extensions] [options] [pref:newfileprefix]
## [audio file extensions] are like: mp3, wav, ogg and so on. (mp3 by default)
## [options] are like: 44100hz, 320kbps, [f-ogg, f-mp3, f-wav, f-flac], -r
## -r means recursive (by default is not)
## f-* means forced output format to one of those [ogg mp3 wav flac]
## *hz means output frequency in Hz
## *kbps means bitrate in kbps
## pref:newfileprefix must be the last parameter on the line, empty is allowed
## It are all optional, by default will be used detected parameters
## -h or help gives this small help
## There are not all checks, so the probability of failure is high.
## Author Andrew S. License GPLv2 Tested with ffmpeg 4.0.2 
## https://github.com/quarkscript/media_works
## https://gitlab.com/quarkscript/media_shell_scripts/
'; exit 0 ; fi
inargs=$(echo $@ | sed 's/,//g' | sed 's/"//g' | sed "s/'//g")
echo '  Prepare:'
rm -f list.tmp thread*list.tmp
proc_fmts="mp3 ogg wav flac" ## set the supported forced output formats
for pfg in $proc_fmts; do
    reserved+="f-$pfg "
done
reserved+=" -r [0-9][0-9][0-9][0-9][0-9][0-9]hz [0-9][0-9][0-9][0-9][0-9]hz [0-9][0-9][0-9][0-9]hz [0-9][0-9][0-9]kbps [0-9][0-9]kbps "
extns=$inargs
for ii in $reserved; do
    extns=$(echo $extns | sed "s/$ii//g")
done
extns=$(echo $extns | sed "s/pref\:.*//g")
if [ -z "$extns" ]; then
    extns=mp3
    echo "By default mp3 files will be processed"
else
    echo "Will be processed: $(echo $extns | sed 's/  / /g' | sed 's/ /, /g') files"
fi
if $(echo $inargs | grep -q --regexp='f-'); then
    outformat=$(echo $inargs | sed "s/.*f-//g" | sed 's/ .*//g')
    echo "Output format forced to $outformat"
    ok=""
    for chk in $proc_fmts; do
        if [ "$outformat" == "$chk" ]; then
            ok=ok
            break
        fi
    done
    if [ -z "$ok" ]; then
    echo "
    Wrong output format: $outformat
    "
    exit 1
    fi
else
    outformat=""
fi 
if $(echo $inargs | grep -q --regexp="hz"); then
    freq=$(echo $inargs | sed 's/hz.*//g' | sed 's/.* //g')
    echo $freq"Hz will be forced to all files during normalization"
else
    freq=""
fi
if $(echo $inargs | grep -q --regexp="kbps"); then
    bitrate="$(echo $inargs | sed 's/kbps.*//g' | sed 's/.* //g')"
    echo $bitrate"kbps will be forced to all files during normalization"
else
    bitrate=""
fi
threads=$(($(grep 'model name' /proc/cpuinfo --count)+1))
echo "Up to $threads threads can be used simultaneously"
if $(echo $inargs | grep -q --regexp='-r'); then
    echo "-r is specified, all files from all subdirs will be processed"
    mdp=""
else 
    echo "-r is not specified, files from subfolders will be not processed"
    mdp="-maxdepth 1"
fi
prefix=$(echo $inargs | sed "s/.*pref\://g")
#if [ "$(echo $inargs | grep -c --regexp='pref:')" -gt 0 ] && [ ! -z "$prefix" ]; then
## allow empty prefix, no overwrite for duplicates
if [ "$(echo $inargs | grep -c --regexp='pref:')" -gt 0 ]; then
    echo "Normalized files prefix specified to '$prefix'"
else
    prefix=n_
    echo "Default normalized files prefix is '$prefix'"
fi
for iii in $extns; do
    if [ -z "$prefix" ]; then
        find  $mdp -name "*.$iii" | sed 's|\.\/||g'>>list.tmp
    else
        find  $mdp -not -name "$prefix*" -name "*.$iii" | sed 's|\.\/||g'>>list.tmp
    fi
done
filesnum=$(wc -l list.tmp | sed 's/ list.tmp//g')
if [ "$filesnum" -eq "0" ]; then
    echo "Files with extensions: $(echo $extns | sed 's/ /, /g') not found. Exit"
    exit 0
else
    count=1
    ## check minimal limit of files for multithreads processing
    if [ "$filesnum" -gt "$(($threads*0+2))" ]; then
        count_inc=1
    else
        count_inc=0
    fi
    for (( jj=1; jj <= $filesnum; ++jj )); do
        if [ "$count" -eq "$(($threads+1))" ]; then
            count=1
        fi
        head -n $jj list.tmp 2>&1 | tail -n 1 >>"thread_"$count"_list.tmp"
        count=$(($count+$count_inc))
    done
    rm -f tmp.tmp
fi
if [ "$filesnum" -eq 1 ]; then
    echo "only one file will be normalized"
else
    echo "$filesnum files will be normalized at all"
fi
echo "  Processing:"
gainlim(){
    limvar=$(echo $1 | sed 's/dB//g')
    limval=$(echo $2 | sed 's/dB//g')
    fracvar=$(echo $limvar | sed 's/.*\.//g')
    fracval=$(echo $limval | sed 's/.*\.//g')
    if [ "${#fracvar}" -gt "${#fracval}" ]; then fracpow=${#fracvar} ; else fracpow=${#fracval} ; fi
    tmprez=$((10#$(echo $limvar | sed 's/\..*//g')*(10**$fracpow)+10#$fracvar*(10**($fracpow-${#fracvar}))-(10#$(echo $limval | sed 's/\..*//g')*(10**$fracpow)+10#$fracval*(10**($fracpow-${#fracval})))))
    if $(echo $tmprez | grep -q --regexp='-'); then 
        echo 0.0 
    else 
        rezfract=$(echo $((10#$tmprez-(10#$tmprez/(10**$fracpow))*(10**$fracpow))) | sed 's/-//g')
        echo $tmp$(echo $(($tmprez/(10**$fracpow))) | sed 's/-//g').$(echo $((10**($fracpow-${#rezfract}))) | sed 's/1//g')"$rezfract"
    fi
}
normalize_it() {
    flsnum=$(wc -l $1 | sed "s/ $1//g")
    for (( cycle_list=1; cycle_list <= $flsnum; ++cycle_list )); do
        filename=$(head -n $cycle_list $1 2>&1 | tail -n 1)
        fileprop=$(ffmpeg -hide_banner -i "$filename" 2>&1 | grep --regexp=Audio --regexp=bitrate)
        fr=$(echo $fileprop | sed 's\ Hz.*\\g' | sed 's\.*, \\g')
        cod=$(echo $fileprop | sed 's\.*Audio: \\g' | sed 's\,.*\\g' | sed 's\ (.*\\g')
        bitrate=$(echo $fileprop | sed 's\ kb/s.*\\g' | sed 's\.* \\g')
        ## Get file properties by ffmpeg. Depending of ffmpeg version, cut-mask may vary and may not work
        ## If something goes wrong you can uncomment next 4 lines and correct cut-mask for your version of ffmpeg
#         echo "$filename
#         $fileprop
#         $fr    $cod    $bitrate"
#         exit 0
        if [ ! -z "$2" ]; then
            cod=$2
        fi
        if [ ! -z "$4" ]; then
            bitrate=$4
        fi
        if [ ! -z "$3" ]; then
            fr=$3
        fi
        if $(echo $filename | grep -q --regexp="/"); then
            fnt=$(echo $filename | sed 's/.*\///g')
            filepath=$(echo $filename | sed "s/$fnt//g")
        else
            filepath=""
            fnt="$filename"
        fi
        if [ ! -z "$2" ]; then
            outfile="$filepath$5${fnt%.*}.$2"
        else
            outfile="$filepath$5$fnt"
        fi
        ## amplifyer limit - 0.001dB applied only if it less then generateg gain
        ampl=$(gainlim $(ffmpeg -hide_banner -i "$filename" -af "volumedetect" -f null /dev/null 2>&1 | grep max_volume | grep max_volume | grep -o -E "[- ][0-9][0-9.][0-9 .][0-9 ]" | sed -e 's/-//g' | sed -e 's/ //g') 0.001dB)
        if [ "$cod" == "mp3" ]; then
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -r:a "$fr"Hz -c:a libmp3lame -b:a "$bitrate"k "$outfile"
        elif [ "$cod" == "vorbis" ] || [ "$cod" == "ogg" ]; then
            if [ "$bitrate" -le 127 ]; then
                q=3
            elif [ "$bitrate" -le 159 ]; then
                q=4
            elif [ "$bitrate" -le 190 ]; then
                q=5
            elif [ "$bitrate" -le 220 ]; then
                g=6
            elif [ "$bitrate" -le 250 ]; then
                q=7
            elif [ "$bitrate" -le 300 ]; then
                q=8
            elif [ "$bitrate" -le 500 ]; then
                q=9
            else
                q=10
            fi
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -ar $fr -c:a libvorbis -aq $q -f oga "$outfile"
        elif [ "$cod" == "opus" ]; then
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -ar $fr -c:a libopus -b:a "$bitrate"k "$outfile"
        elif [ "$cod" == "flac" ]; then
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -ar $fr -c:a flac -compression_level 8 "$outfile"
        elif [ "$cod" == "wav" ]; then
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -ar $fr "$outfile"
        else
            ffmpeg -hide_banner -i "$filename" -af volume="$ampl"dB -ar $fr -b:a "$bitrate"k "$outfile"
        fi
    done
}
for (( jjj=1; jjj <= $(find -maxdepth 1 -name 'thread*list.tmp' | grep -c thread_); ++jjj )); do
    normalize_it "thread_"$jjj"_list.tmp" "$outformat" "$freq" "$bitrate" "$prefix" &
done
wait
rm -f thread*list.tmp list.tmp
