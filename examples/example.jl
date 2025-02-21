using MDSplus

using Printf

function status_ok(stat)
    (stat & 1) == 1
end

function get_signal_length(sig)
    s = [0]
    idesc = descr(Int32, size(s), s)
    stat = MdsValue("SIZE($sig)", idesc)
    return s[1]
end

function run_example(shot)
    socket = MdsConnect("atlas.gat.com")

    stat = MdsOpen("EFIT01",shot)

    s = get_signal_length("\\AMINOR")

    data = zeros(Float64, s)
    sigdesc = descr(data)
    stat = MdsValue("\\AMINOR", sigdesc)

    time = zeros(Float64, s)
    timedesc = descr(time)
    stat = MdsValue("DIM_OF(\\AMINOR)", timedesc)

    for i=1:10
        println(@sprintf("%2i X: %6.2f Y: %6.2f",i,time[i],data[i]))
    end

    MdsDisconnect()
end

run_example(107000)
