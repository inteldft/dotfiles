
set -l hex $hex (seq 0 15)

set -l color
for x in $hex
    set color $color (printf '%x' $x)
end

for i in $color
    for j in $color
        for k in $color
            set_color -b $i$j$k
            echo -ns ' ' $i$j$k ' '
        end
        echo
    end
end

