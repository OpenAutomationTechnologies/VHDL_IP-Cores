view wave
add wave /* -r
set broken 0
onbreak {
    set broken 1
    resume
}
run -all
if { $broken } {
    puts "failure"
    quit -code 1
} else {
    puts "success"
    quit -code 0
}
